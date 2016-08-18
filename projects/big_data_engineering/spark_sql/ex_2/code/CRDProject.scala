import org.apache.spark.SparkContext;
import org.apache.spark.SparkContext._;
import org.apache.spark.SparkConf;
import org.apache.hadoop.conf.Configuration;
import org.apache.spark.sql;
import org.apache.spark.sql.SQLContext;
import org.apache.spark.sql._
import org.apache.spark.sql.types._;
import org.apache.spark.sql.functions._;

object CRDProject {

  def main(args: Array[String]) {
    
    //Shared config
    val config = new Configuration();
    val uri = "hdfs://localhost:8020/";
    config.set("fs.defaultFS", uri);
    //config.set("fs.defaultFS", "hdfs://master:9000/");

    //Create Spark ctx  
    val conf = new SparkConf().setAppName("CDRReportApp Application").setMaster("local[2]");
    val sc = new SparkContext(conf);
    
    //A. Load the file as table in SparkSQL and register template
    val sqlContext = new org.apache.spark.sql.SQLContext(sc);
    import sqlContext.implicits._; //necessary and after sqlContext is created, else '.toDF' will fail to comppile
    
    //Create the schema, the point is to create a schema is not space in the columns name
    val cdrSchema =  StructType(Array(
                             StructField("VISITOR_LOCN", IntegerType, true),
                             StructField("CALL_DURATION_SEC", IntegerType, true),
                             StructField("PHONE_NO", LongType , true),
                             StructField("ERROR_CODE", StringType, true)));
    
    //Load the data and add the schema
    val cdrDf = sqlContext.read
      .format("com.databricks.spark.csv")
      .option("header", "true") // Use first line of all files as header
      /*.option("inferSchema", "true") // Automatically infer data types*/
      .schema(cdrSchema)
      .load(uri + "user/fred_cdr/sample_data/cdr_data/");
    
    //B. Find the 10 most frequent drop out numbers
    cdrDf.registerTempTable("CDR");
    val cdrData = sqlContext.sql("SELECT VISITOR_LOCN,CALL_DURATION_SEC,PHONE_NO,ERROR_CODE FROM CDR")
    val cdrTop10 = sqlContext.sql("SELECT PHONE_NO, COUNT(PHONE_NO) AS COUNT_DROP_OUT FROM CDR GROUP BY PHONE_NO ORDER BY COUNT(PHONE_NO) DESC")
    println("Call back the following numbers: " + cdrTop10.take(10).toList);
    
    //C. Find all the relevant information for the roaming provider (for the 10 most frequent drop out numbers)
    val join = cdrData.join(cdrTop10, cdrData("PHONE_NO") === cdrTop10("PHONE_NO"));
    println("Log for the roaming provider (10 most frequent drop outs) : " + join.collectAsList);
  }
}