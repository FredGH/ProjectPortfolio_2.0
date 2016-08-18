
import org.apache.spark.SparkContext;
import org.apache.spark.SparkContext._;
import org.apache.spark.SparkConf;
import org.apache.hadoop.conf.Configuration;

object Sco {

  def main(args: Array[String]) {
    //Step 1 - Set-up 
    val uri = "hdfs://localhost:8020/";
    val inFilePath = "/user/fred/sample_data/salary_info";
    val inFilePathMin = "/user/fred/sample_data/salary_info_min";
    val inFilePathMax = "/user/fred/sample_data/salary_info_max";
    val config = new Configuration();
    config.set("fs.defaultFS", uri);
    val txtFilePath = uri + inFilePath;
    //Step 2 - Create Spark Ctx  
    val conf = new SparkConf().setAppName("Sco Application").setMaster("local[2]")
    val sc = new SparkContext(conf)
    val txtFileLines = sc.textFile(txtFilePath,2).cache()
    //Step 3 - Generate relevant Rdds and store to HDFS
    val rdd = sc.textFile(txtFilePath);
    val lineCount = rdd.count();
    println("lineCount: "+ lineCount);
    //split the cols and filter out heades
    val splits_data_only = rdd.map(x => (x.split(",")(0), x.split(",")(1))).filter(x => x._1 != "dptid");
    val reduce_max = splits_data_only.reduceByKey((x,y)=>if (x>y) {x}  else {y}  );
    val reduce_min = splits_data_only.reduceByKey((x,y)=>if (x>y) {y}  else {x}  );
    println("reduce_max: "+ reduce_max.collect().toList);
    println("reduce_min: "+ reduce_min.collect().toList);
    //save to hdfs
    println("Start Saving to HHDFS");
    reduce_min.saveAsTextFile(uri + inFilePathMin)
    reduce_max.saveAsTextFile(uri + inFilePathMax)
    println("End Saving to HHDFS");
    
  }
}