import org.apache.spark.SparkContext;
import org.apache.spark.SparkContext._;
import org.apache.spark.SparkConf;
import org.apache.hadoop.conf.Configuration;
import org.apache.spark.sql;
import org.apache.spark.sql.SQLContext;
import org.apache.spark.sql._
import org.apache.spark.sql.types._;
import org.apache.spark.sql.functions._;

object StockPrices {

  //Note1: ensure the app config is set as: -Xms128m -Xmx512m -XX:MaxPermSize=300m -ea
  //to avoid memory expection.
  //1. Right click on the .scal file
  //2. Run As configuration => tab Argument => VM args =  -Xms128m -Xmx512m -XX:MaxPermSize=300m -ea
  //3. Apply and Run
  //Note2: Refer to https://github.com/databricks/spark-csv doc
  def main(args: Array[String]) {

    //Shared config
    val config = new Configuration();
    config.set("fs.defaultFS", "hdfs://localhost:8020/");

    //Create Spark Ctx  
    val conf = new SparkConf().setAppName("StockPrices Application").setMaster("local[2]");
    val sc = new SparkContext(conf);
    
    //A. Load the file as table in SparkSQL and register template
    val sqlContext = new org.apache.spark.sql.SQLContext(sc);
    import sqlContext.implicits._; //necessary and after sqlContext is created, else '.toDF' will fail to comppile
    
    //Create the schema, the point is to create a schema is not space in the columns name
    val stockPricesSchema =  StructType(Array(
                             StructField("StockName", StringType, true),
                             StructField("UnitsTraded", IntegerType, true),
                             StructField("SODPrice", FloatType, true),
                             StructField("EODPrice", FloatType, true),
                             StructField("StockMarket", StringType, true)));
    
    //Load the data and add the schema
    val stockPricesDf = sqlContext.read
      .format("com.databricks.spark.csv")
      .option("header", "true") // Use first line of all files as header
      /*.option("inferSchema", "true") // Automatically infer data types*/
      .schema(stockPricesSchema)
      .load("file:///home/edureka/workspace/StockPricesApp1/data/StockPrices.csv");
   
    //B. Find the highest gainer stock of the given trading day in BSE and NSE
    stockPricesDf.registerTempTable("StockPrices");
    val stockPrices = sqlContext.sql("SELECT * FROM StockPrices")
    val pnlDf = stockPrices.withColumn("IntraPnl", intraDayPnl()($"SODPrice", $"EODPrice"));
    val bsehighestPnlStockGainer = pnlDf.filter("StockMarket = 'BSE'").orderBy(desc("IntraPnl")).first();
    val nsehighestPnlStockGainer = pnlDf.filter("StockMarket = 'NSE'").orderBy(desc("IntraPnl")).first();
    println("Highest BSE Stock Pnl: " + bsehighestPnlStockGainer);
    println("Highest NSE Stock Pnl: " + nsehighestPnlStockGainer); 
    
    //C.Find  the biggest loser stock of the given trading day in BSE and NSE
    val bselowestPnlStockGainer = pnlDf.filter("StockMarket = 'BSE'").orderBy(asc("IntraPnl")).first();
    val nselowestPnlStockGainer = pnlDf.filter("StockMarket = 'NSE'").orderBy(asc("IntraPnl")).first();
    println("Lowest BSE Stock Pnl: " + bselowestPnlStockGainer);
    println("Lowest NSE Stock Pnl: " + nselowestPnlStockGainer);
    
    //D. Find  the highest traded stock (maximum units sold)
    val highestTradedStock = stockPricesDf.orderBy(desc("UnitsTraded")).first();
    println("Highest traded stock: " + highestTradedStock);
    
    //E. Find  the lowest traded stock (maximum units sold)
    val lowestTradedStock = stockPricesDf.orderBy(asc("UnitsTraded")).first();
    println("Lowest traded stock: " + lowestTradedStock);
    
    //F. Find the total units sold across all markets, all stocks
    val totalUnitSold = stockPricesDf.agg(sum($"UnitsTraded"));
    println("Total Unit Sold: " + totalUnitSold.collectAsList());
    
    //G. Find the total traded amount across all markets, all stocks
    val tradedAmountAtMidDf = stockPrices.withColumn("TradedAmountAtMid", tradedAmoutAtMid()($"UnitsTraded", $"SODPrice", $"EODPrice"));
    val totalTradedAmountAtMid = tradedAmountAtMidDf.agg(sum($"TradedAmountAtMid"));
    println("Total Traded Amount At Mid: " + totalTradedAmountAtMid.collectAsList());
  }
  
  //Calculate the Intra Day Profit and Loss      
  def intraDayPnl() = udf((sodPrice:Float, eodPrice:Float) => (eodPrice-sodPrice)/sodPrice);
  //Calculate the Traded Amount at Mid (i.e. sod+eod/2)
  def tradedAmoutAtMid() = udf((unitsTraded: Integer, sodPrice:Float, eodPrice:Float) => unitsTraded * (eodPrice+sodPrice)/2);
}
