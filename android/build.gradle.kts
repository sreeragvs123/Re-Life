allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(name)
    layout.buildDirectory.set(newSubprojectBuildDir)
}

// this must be at top-level, not inside subprojects {}
evaluationDependsOn(":app")

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
