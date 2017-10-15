//import required libraries
import org.apache.spark.SparkContext;
import org.apache.spark.SparkContext._;
import org.apache.spark.SparkConf;
import org.apache.hadoop.conf.Configuration;

import org.apache.spark.sql;
import org.apache.spark.sql.SQLContext;
import org.apache.spark.sql._
import org.apache.spark.sql.types._;
import org.apache.spark.sql.functions._;

//******************************************************************************************
//Step 1 - Set-up
//******************************************************************************************
var now = System.currentTimeMillis;
config.set("fs.defaultFS", uri);
var folderPath = "hdfs:///user/fmare001/"
//Create the SQLContext
val sc: SparkContext; 
val sqlContext = new org.apache.spark.sql.SQLContext(sc);
// For implicit conversions like converting RDDs to DataFrames
import org.apache.spark.implicits._
import sqlContext.implicits._;
var timeElapsed = System.currentTimeMillis - now
println("****Set-up Time(ms): " + timeElapsed);

//******************************************************************************************
//Step 2 - Create the business object classes
//******************************************************************************************
now = System.currentTimeMillis;
case class DelayRow(Year: String, Month: String,DayofMonth:String, DayOfWeek:String, UniqueCarrier:String,TailNum
:String,DepDelay:String, Origin:String, Dest:String, Distance:String,Cancelled:String, Diverted:String); 
case class AirportRow(Iata: String, Airport: String,City:String, State:String, Country:String );
case class CarrierRow(Code: String, Description: String );
case class PlaneDataRow(TailNum: String, IssueYear: String );
timeElapsed = System.currentTimeMillis - now
println("****Business Object Creation Time(ms): " + timeElapsed);
//******************************************************************************************

//******************************************************************************************
//Step 3 - Create shared functions
//******************************************************************************************
now = System.currentTimeMillis;
//Reads the airports csv file(e.g. 2008.csv) from a file path, then
//map it to the AirportRow business object and
//returns result as a Dataframe  
def get_airport_df (fileName :String) : DataFrame = {
   val rdd = sc.textFile(folderPath+fileName);
   val df = rdd.map(_.split(",")).map(p => AirportRow(p(0).toString, p(1).toString, p(2).toString, p(3).toString, p(4).toString)).toDF();
   return df;
}
//Reads the plane-data csv file from a file path, then
//map it to the CarrierRow business object and
//returns result as a Dataframe
def get_plane_data_df (fileName :String) : DataFrame = {
   val rdd = sc.textFile(folderPath+fileName);
   val df = rdd.map(_.split(",")).map(p => PlaneDataRow(p(0), p(8))).toDF();
   return df;
}
//Reads the carriers csv file from a file path, then
//map it to the CarrierRow business object (after having removed double quotes) and 
//returns result as a Dataframe
def get_carrier_df (fileName :String) : DataFrame = {
   val rdd = sc.textFile(folderPath+fileName);
   val df = rdd.map(_.split(",")).map(p => CarrierRow(p(0).replace("\"",""), p(1).replace("\"",""))).toDF();
   return df;
}
//Reads the 'delay/year' csv file (e.g. 2008.csv) from a file path, then
//map it to the DelayRow business object, remove header and
//returns result as a Dataframe
def get_delay_df (fileName :String) : DataFrame = {
   val rdd = sc.textFile(folderPath+fileName);
   val df = rdd.map(_.split(",")).map(p => DelayRow(p(0), p(1), p(2), p(3), p(8), p(10), p(15), p(16), p(17), p(18), p(21), p(23))).filter(x => x.Year != "Year").toDF();
   return df;
}
timeElapsed = System.currentTimeMillis - now
println("****Shared Function Creation Time(ms): " + timeElapsed);


//******************************************************************************************
//Step 4 - Load data into RDDs
//******************************************************************************************
now = System.currentTimeMillis;
val airport_df = get_airport_df("airports.csv");
val carrier_df = get_carrier_df("carriers.csv");
val plane_data_df = get_plane_data_df("plane-data.csv");
val delay_2008_df = get_delay_df("2008.csv");
val delay_2007_df = get_delay_df("2007.csv");
val delay_2006_df = get_delay_df("2006.csv");
val delay_2005_df = get_delay_df("2005.csv");
val delay_2004_df = get_delay_df("2004.csv");
val delay_2003_df = get_delay_df("2003.csv");
val delay_2002_df = get_delay_df("2002.csv");
val delay_2001_df = get_delay_df("2001.csv");
val delay_2000_df = get_delay_df("2000.csv");
val delay_1999_df = get_delay_df("1999.csv");
val delay_1998_df = get_delay_df("1998.csv");
val delay_1997_df = get_delay_df("1997.csv");
val delay_1996_df = get_delay_df("1996.csv");
val delay_1995_df = get_delay_df("1995.csv");
val delay_1994_df = get_delay_df("1994.csv");
val delay_1993_df = get_delay_df("1993.csv");
val delay_1992_df = get_delay_df("1992.csv");
val delay_1991_df = get_delay_df("1991.csv");
val delay_1990_df = get_delay_df("1990.csv");
val delay_1989_df = get_delay_df("1989.csv");
val delay_1988_df = get_delay_df("1988.csv");
val delay_1987_df = get_delay_df("1987.csv");
timeElapsed = System.currentTimeMillis - now
println("****Data Load Time(ms): " + timeElapsed);


//******************************************************************************************
//Step 5 - Union all 'delay/year' dataframe to form a unique dataframe containing all delay
//******************************************************************************************
now = System.currentTimeMillis;
val all_delay_df = delay_2008_df.unionAll(delay_2007_df).unionAll(delay_2006_df).unionAll(delay_2005_df).unionAll(delay_2004_df).unionAll(delay_2003_df).unionAll(delay_2002_df).unionAll(delay_2001_df).unionAll(delay_2000_df).unionAll(delay_1999_df).unionAll(delay_1998_df).unionAll(delay_1997_df).unionAll(delay_1996_df).unionAll(delay_1995_df).unionAll(delay_1994_df).unionAll(delay_1993_df).unionAll(delay_1992_df).unionAll(delay_1991_df).unionAll(delay_1990_df).unionAll(delay_1989_df).unionAll(delay_1988_df).unionAll(delay_1987_df);
timeElapsed = System.currentTimeMillis - now
println("****Data Union Creation Time(ms): " + timeElapsed);

//******************************************************************************************
//Step 6 - Perform report queries
//******************************************************************************************

//SHARED TRANSFORMS
now = System.currentTimeMillis;
//As alias are not supported in Spark v1.4, I had to duplicate the airport rdd and change the coulmn name
val airport_dest_df = airport_df.withColumnRenamed("Airport", "Dest_Airport");
val airport_origin_df = airport_df.withColumnRenamed("Airport", "Origin_Airport");
timeElapsed = System.currentTimeMillis - now
println("****Shared Transforms Creation Time(ms): " + timeElapsed);

//QUERY 1 - What route most suffer from delays (Top 10 / broken down bby year)
now = System.currentTimeMillis;
//Find all cancellations per aida origin and dest and generate the number of cancellations.
val cancellations_df = all_delay_df.groupBy("Year","Origin", "Dest").agg(sum("Cancelled"));
//Now join on the airport_dest_df and airport_origin_df to get the readable airport names 
cancellations_df.join(airport_origin_df, cancellations_df("Origin") === airport_origin_df("Iata"),"left_outer").join(airport_dest_df, cancellations_df("Dest") === airport_dest_df("Iata"),"left_outer").select("Year","Origin_Airport","Origin", "Dest_Airport","Dest","SUM(Cancelled)").orderBy(desc("SUM(Cancelled)")).show(5);
timeElapsed = System.currentTimeMillis - now
println("****Query 1 Response Time(ms): " + timeElapsed);

//QUERY 2 -  What destinations most often suffer delays (Top 10 / broken down bby year)?
now = System.currentTimeMillis;
//Find the sum of delays per destination and order by desc order of sum of delays
val delay_per_destination_df = all_delay_df.groupBy("Year","Dest", "Dest").agg(sum("DepDelay"));
//Now join with the airport_dest_df to get to the airport information
delay_per_destination_df.join(airport_dest_df, delay_per_destination_df("Dest") === airport_df("Iata") ,"left_outer").select("Year","Dest_Airport","Dest","SUM(DepDelay)").orderBy(desc("SUM(DepDelay)")).show(10);
timeElapsed = System.currentTimeMillis - now
println("****Query 2 Response Time(ms): " + timeElapsed);

//QUERY 3 -  What are the airlines that suffer from the longest delays (Top 10 / broken down bby year)?
now = System.currentTimeMillis;
//Find the sum of delays per carrier 
val delay_per_carrier_df = all_delay_df.groupBy("Year","UniqueCarrier").agg(sum("DepDelay"));
//Now join with the carrier_df to get to the carrier information, and order by desc order of sum of delays
delay_per_carrier_df.join(carrier_df, delay_per_carrier_df("UniqueCarrier") === carrier_df("Code") ,"left_outer").select("Year","UniqueCarrier","SUM(DepDelay)").orderBy(desc("SUM(DepDelay)")).show(10);
timeElapsed = System.currentTimeMillis - now
println("****Query 3 Response Time(ms): " + timeElapsed);

//QUERY 4 -  When is  best i)year, ii) month of year, ii) day of month or iii) day of week to fly to minimise delays (Top 5)?
//4.1
now = System.currentTimeMillis;
val delay_per_year_df = all_delay_df.groupBy("Year").agg(sum("DepDelay")).orderBy(asc("SUM(DepDelay)")).select("Year","SUM(DepDelay)").select("Year","SUM(DepDelay)");
delay_per_year_df.show(5);
timeElapsed = System.currentTimeMillis - now
println("****Query 4.1 Response Time(ms): " + timeElapsed);

//4.2
now = System.currentTimeMillis;
val delay_per_year_month_df = all_delay_df.groupBy("Month").agg(sum("DepDelay")).orderBy(asc("SUM(DepDelay)")).select("Month","SUM(DepDelay)");
delay_per_year_month_df.show(5);
timeElapsed = System.currentTimeMillis - now
println("****Query 4.2 Response Time(ms): " + timeElapsed);

//4.3
now = System.currentTimeMillis;
val delay_per_year_dayofmonth_df = all_delay_df.groupBy("DayofMonth").agg(sum("DepDelay")).orderBy(asc("SUM(DepDelay)")).select("DayofMonth","SUM(DepDelay)");
delay_per_year_dayofmonth_df.show(5);
timeElapsed = System.currentTimeMillis - now
println("****Query 4.3 Response Time(ms): " + timeElapsed);

//4.4
now = System.currentTimeMillis;
val delay_per_year_dayofweek_df = all_delay_df.groupBy("DayOfWeek").agg(sum("DepDelay")).orderBy(asc("SUM(DepDelay)")).select("DayOfWeek","SUM(DepDelay)");
delay_per_year_dayofweek_df.show(5);
timeElapsed = System.currentTimeMillis - now
println("****Query 4.4 Response Time(ms): " + timeElapsed);

//QUERY 5 -  Do older planes suffer more delays?
now = System.currentTimeMillis;
all_delay_df.join(plane_data_df, all_delay_df("TailNum") === plane_data_df("TailNum") ,"left_outer").groupBy("Year").agg(sum("DepDelay")).orderBy(desc("SUM(DepDelay)")).show(20);
timeElapsed = System.currentTimeMillis - now
println("****Query 5 Response Time(ms): " + timeElapsed);