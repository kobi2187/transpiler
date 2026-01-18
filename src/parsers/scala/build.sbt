name := "scala-to-xlang"

version := "1.0.0"

scalaVersion := "2.13.12"

libraryDependencies ++= Seq(
  "org.scalameta" %% "scalameta" % "4.8.15"
)

// Assembly settings for creating fat JAR
assembly / assemblyMergeStrategy := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case x => MergeStrategy.first
}

assembly / assemblyJarName := "scala-to-xlang.jar"

assembly / mainClass := Some("ScalaToXLangParser")
