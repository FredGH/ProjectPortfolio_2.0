name := "Sco Application"

version := "1.0"

scalaVersion  := "2.10.4"

libraryDependencies += "org.apache.spark" %% "spark-core" % "1.5.2"

libraryDependencies ++= Seq(
  "org.apache.hadoop" % "hadoop-client" % "2.7.0"
)
