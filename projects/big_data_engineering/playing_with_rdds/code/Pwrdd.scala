import org.apache.spark.SparkContext;
import org.apache.spark.SparkContext._;
import org.apache.spark.SparkConf;
import org.apache.hadoop.conf.Configuration;

object Pwrdd {

  def main(args: Array[String]) {

    //Shared config
    val uri = "hdfs://localhost:8020/";
    val config = new Configuration();
    config.set("fs.defaultFS", uri);
    //Create Spark Ctx  
    val conf = new SparkConf().setAppName("Pwrdd Application").setMaster("local[2]");
    val sc = new SparkContext(conf);
    
    //Set-up 
    val file1Path = "/user/fred/sample_data/file1";
    val file2Path = "/user/fred/sample_data/file2";
    val incomeInfoPath = "/user/fred/sample_data/income_info";
    val pancardInfoPath = "/user/fred/sample_data/pancard_info";
    val txtFile1Path = uri + file1Path;
    val txtFile2Path = uri + file2Path;
    val txtIncomeInfoPath = uri + incomeInfoPath;
    val txtpancardInfoPath = uri + pancardInfoPath;
    
    //A. Find the (customer_name, city, total_amount, year) for the customers 
    //whose total purchase_amt is more than a threshold
    //...Generate relevant Rdds
    val rddFile1 = sc.textFile(txtFile1Path);
    val rddFile2 = sc.textFile(txtFile2Path);
    //...Split files on CustomerId to enable join, 
    //filter out the header column, and set the threshold
    val file1Split = rddFile1.map(x => (x.split(",")(0), x)).filter(x => x._2.split(",")(0) != "customer_id");
    val file2Split = rddFile2.map(x => (x.split(",")(0), x)).filter(x => x._2.split(",")(0) != "customer_id").filter(x=>x._2.split(",")(1).toFloat >= 9000.0);
    //...Print result
    println("res: " + file1Split.join(file2Split).collect.toList);
    
    //B.Find who have the PAN CARD information, but no income information
    //...Generate relevant Rdds
    val rddIncomeInfo = sc.textFile(txtIncomeInfoPath);
    val rddPancardInfo = sc.textFile(txtpancardInfoPath);
    //...Split files on recordid to enable join, 
    //filter out the header column
    val incomeInfoSplit = rddIncomeInfo.map(x => (x.split(",")(0), x)).filter(x => x._2.split(",")(0) != "recordid");
    val pancardInfoSplit = rddPancardInfo.map(x => (x.split(",")(0), x)).filter(x => x._2.split(",")(0) != "recordid");
    //join the two sets and filter in records with no income information
    val res1 = pancardInfoSplit.leftOuterJoin(incomeInfoSplit).filter(x=>x._2._2 == None);
    println("res: " + res1.collect.toList);
      
    //C. Find who have the income information, and corresponding PANCARD entry, 
    //but without any PAN CARD number
    val res2 = incomeInfoSplit.join(pancardInfoSplit).filter(x=>x._2.productElement(1).toString().contains(",") == false);
    println("res: " + res2.collect.toList);
    
    //D. Find the records which are present only in income information, 
    //but not present in PAN CARD information
    val res3 = incomeInfoSplit.leftOuterJoin(pancardInfoSplit).filter(x=>x._2.productElement(1).toString().contains("None"));;
    println("res: " + res3.collect.toList);
  }
}
