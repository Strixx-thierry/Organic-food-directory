// Top-level repositories (keep yours)
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Your custom build directory redirection (keep if needed for your setup)
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Your custom clean task (keep if needed)
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
