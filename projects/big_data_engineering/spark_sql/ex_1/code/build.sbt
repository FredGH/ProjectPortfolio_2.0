name := "StockPricesApp Application"

version := "1.0"

scalaVersion  := "2.10.4"

libraryDependencies += "org.apache.spark" %% "spark-core" % "1.6.1"
libraryDependencies += "org.apache.spark" %% "spark-sql" % "1.6.1"
libraryDependencies += "com.databricks" %% "spark-csv" % "1.4.0"

libraryDependencies ++= Seq(
  "org.apache.hadoop" % "hadoop-client" % "2.7.0"
)
