plugins {
    kotlin("jvm") version "1.9.22"
    kotlin("plugin.serialization") version "1.9.22"
    application
}

group = "transpiler.kotlin"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    // Kotlin compiler for PSI access
    implementation("org.jetbrains.kotlin:kotlin-compiler-embeddable:1.9.22")

    // JSON serialization
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2")

    // Testing
    testImplementation(kotlin("test"))
}

application {
    mainClass.set("transpiler.kotlin.KotlinToXLangParser")
}

tasks.test {
    useJUnitPlatform()
}

tasks.jar {
    manifest {
        attributes["Main-Class"] = "transpiler.kotlin.KotlinToXLangParser"
    }

    // Create a fat JAR with all dependencies
    duplicatesStrategy = DuplicatesStrategy.EXCLUDE
    from(configurations.runtimeClasspath.get().map { if (it.isDirectory) it else zipTree(it) })
}

kotlin {
    jvmToolchain(17)
}
