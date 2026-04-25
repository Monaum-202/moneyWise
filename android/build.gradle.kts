allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
}

subprojects {
    if (project.state.executed) {
        fixProject(project)
    } else {
        project.afterEvaluate {
            fixProject(this)
        }
    }
}

fun fixProject(p: Project) {
    if (p.hasProperty("android")) {
        val android = p.extensions.getByName("android")
        
        // Force compileSdkVersion to at least 34 to avoid lStar error
        try {
            val setCompileSdkVersion = android.javaClass.getMethod("setCompileSdkVersion", Any::class.java)
            setCompileSdkVersion.invoke(android, 34)
        } catch (e: Exception) {
            try {
                val setCompileSdk = android.javaClass.getMethod("setCompileSdk", Integer::class.java)
                setCompileSdk.invoke(android, 34)
            } catch (e2: Exception) {}
        }

        try {
            val getNamespace = android.javaClass.getMethod("getNamespace")
            if (getNamespace.invoke(android) == null) {
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                
                var packageName: String? = null
                val manifestFile = p.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val manifestContent = manifestFile.readText()
                    val match = Regex("package=\"([^\"]+)\"").find(manifestContent)
                    packageName = match?.groups?.get(1)?.value
                }
                
                if (packageName == null) {
                    packageName = "dev.flutter.plugins.${p.name.replace("-", "_").replace(".", "_")}"
                }
                
                setNamespace.invoke(android, packageName)
            }
        } catch (e: Exception) {
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
