import com.android.build.gradle.BaseExtension
import org.gradle.api.JavaVersion

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Normalmente o Flutter injeta as versões do AGP/Gradle via settings/plugins,
        // então aqui pode ficar vazio dependendo do template.
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Força Java 17 nos subprojects (plugins) para reduzir warnings de Java 8
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            (ext as BaseExtension).compileOptions.apply {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
