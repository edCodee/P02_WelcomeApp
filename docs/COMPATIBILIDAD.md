# WelcomeApp — Correcciones de compatibilidad (PDF Deitel 2016 → Android 16 / API 36)

Proyecto: compileSdk 37, targetSdk 36, minSdk 24. Kotlin integrado en AGP 9.3.2.
Verificado en Pixel 7 y Pixel Tablet, API 36.

Las filas marcadas con **→ §7 #n** no se corrigieron: están documentadas como deuda en [ANALISIS_DISENO.md](ANALISIS_DISENO.md), sección 7.

## Proyecto y build

| #   | PDF                                                           | Problema actual                   | Corrección                                                                                                                               |
| --- | ------------------------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Java (`MainActivity.java` de plantilla)                       | Kotlin es el lenguaje recomendado | `MainActivity.kt`. AGP 9 compila Kotlin sin aplicar el plugin `kotlin-android`                                                           |
| 2   | Company Domain genera el paquete `com.deitel.welcome` (2.3.3) | El asistente ya no pide dominio   | Paquete escrito directamente: `ec.edu.uta.fisei.welcomeapp`                                                                              |
| 3   | `package` en el manifiesto                                    | Movido al build                   | `namespace` y `applicationId` en `app/build.gradle.kts`                                                                                  |
| 4   | Minimum SDK API 23 (2.3.4)                                    | Valores de 2016                   | minSdk 24 (igual que el resto de prácticas), targetSdk 36 (enunciado), compileSdk 37 (lo exige `androidx.core` 1.19.0, commit `b216f06`) |
| 5   | Build en Groovy                                               | Kotlin DSL es el predeterminado   | `build.gradle.kts` y catálogo `gradle/libs.versions.toml`                                                                                |
| 6   | Support Library implícita                                     | Descontinuada                     | AndroidX: core-ktx, appcompat, activity-ktx; Material 1.14.0                                                                             |
| 7   | El PDF no accede a las vistas desde código                    | —                                 | ViewBinding (`ActivityMainBinding`), usado solo para registrar los insets                                                                |

## IDE y asistente (afecta a los pasos del libro, no al código)

| #   | PDF                                                             | Problema actual                                                                                             | Corrección                                                                                |
| --- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| 8   | Plantilla Empty Activity con `RelativeLayout` (2.3.5, 2.4.6)    | Hoy "Empty Activity" genera Compose; la plantilla de vistas es Empty Views Activity, con `ConstraintLayout` | Empty Views Activity; el layout se cambió a `LinearLayout` editando el XML, como en 2.5.3 |
| 9   | Pestañas Design/Text y ventana Properties (2.4.2, 2.5)          | Renombradas                                                                                                 | Modos Code / Split / Design y panel Attributes                                            |
| 10  | Diálogo de propiedades al hacer doble clic en una vista (2.5.4) | Ya no existe                                                                                                | `id`, `orientation`, `text` y `src` se editan en Attributes o en el XML                   |
| 11  | AVD Nexus 4, Nexus 6 y Nexus 9 (2.4.5, 2.6)                     | Retirados del catálogo                                                                                      | Pixel 7 y Pixel Tablet, API 36                                                            |
| 12  | Rotar el AVD con Ctrl+F11 (2.6)                                 | El emulador actual tiene botones de rotación                                                                | Barra lateral del emulador, o `adb` (PRUEBAS §6)                                          |

## Tema y pantalla

| #   | PDF                                                                | Problema actual                                                    | Corrección                                                                                                          |
| --- | ------------------------------------------------------------------ | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| 13  | Tema con barra de app; el nombre se ve arriba (2.8.5, Fig. 2.33)   | La plantilla actual usa Material 3 sin barra                       | `Theme.Material3.DayNight.NoActionBar`: `app_name` solo aparece en el lanzador y en Recientes                       |
| 14  | Texto `#2196F3`, Material Blue 500 (2.5.7)                         | 3,1:1 sobre blanco: no cumple WCAG AA para texto normal (4,5:1)    | `#1565C0`, Blue 800: 5,7:1 (commit `2752b7d`)                                                                       |
| 15  | Barras del sistema opacas                                          | Edge-to-edge obligatorio con targetSdk 35+                         | `enableEdgeToEdge()` + `OnApplyWindowInsetsListener` con `systemBars()` en el layout raíz → limitaciones en §7 #1–3 |
| 16  | Solo modo claro                                                    | El tema DayNight activa el modo oscuro                             | Modo oscuro heredado; el color del texto no se adaptó → §7 #4                                                       |
| 17  | La app gira libremente (2.1)                                       | API 36 ignora las restricciones de orientación en pantallas ≥600dp | Sin cambios: la app nunca bloqueó la orientación                                                                    |
| 18  | Ícono PNG creado con Asset Studio desde `DeitelOrange.png` (2.5.2) | Desde API 26 el lanzador usa íconos adaptativos                    | **No aplicada**: se conserva el ícono de la plantilla → §7 #5                                                       |

## Recursos

| #   | PDF                                                                                           | Problema actual                                                               | Corrección                                                                                           |
| --- | --------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| 19  | Carpeta para tablet: el texto dice `values-xlarge` y luego usa `values-w600dp-h600dp` (2.5.6) | Los calificadores `small`…`xlarge` están obsoletos desde Android 3.2 (API 13) | `values-w600dp-h600dp/dimens.xml` con 80sp; verificado en Pixel Tablet (commit `ddb6d79`)            |
| 20  | Márgenes en `@dimen/activity_*_margin` (Fig. 2.12)                                            | La plantilla actual ya no genera esos recursos                                | `android:padding="16dp"` literal en el layout, anulado en tiempo de ejecución por los insets → §7 #1 |
| 21  | `bug.png` en `drawable/` sin calificador (2.5.1)                                              | Sigue siendo válido                                                           | Igual que el PDF; se escala en pantallas de alta densidad → §7 #6                                    |

## Accesibilidad e internacionalización

| #   | PDF                                                      | Problema actual                                                                                      | Corrección                                                                         |
| --- | -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| 22  | `contentDescription` en la imagen (2.7)                  | Sigue vigente (Lint `ContentDescription`)                                                            | `@string/deitel_logo`, traducido en `values-es`                                    |
| 23  | "TalkBack no está disponible en los AVD" (2.7)           | Ya no es cierto: se instala Android Accessibility Suite desde Play Store en imágenes con Google Play | No verificado con el lector activo → §7 #15                                        |
| 24  | App Custom Locale del emulador (2.8.5)                   | Ya no viene en el emulador                                                                           | Ajustes → Sistema → Idiomas, o `adb shell cmd locale set-app-locales` (PRUEBAS §6) |
| 25  | Ajustes → Language & input → Language (2.8.6)            | La ruta cambió                                                                                       | Ajustes → Sistema → Idiomas                                                        |
| 26  | `app_name` sin traducir y sin marcar (2.8.4)             | Lint `MissingTranslation` tiene severidad error y detiene `gradlew lint`                             | `translatable="false"` (commit `472d101`)                                          |
| 27  | Solo idioma del sistema                                  | Android 13 agrega idioma por app, que requiere `localeConfig`                                        | No aplicado; está fuera del alcance del PDF → §7 #14                               |
| 28  | Guía de color en `google.com/design/spec` (2.2.4, 2.5.7) | URL retirada                                                                                         | El color se eligió por contraste medido (fila 14)                                  |

## Alcance verificado

- Teléfono (Pixel 7) en vertical y horizontal: 40sp. Tablet (Pixel Tablet): 80sp.
- Español con el idioma del sistema; `es-EC` cae en `values-es` gracias a la resolución de idiomas de API 24+.
- Contraste calculado con la fórmula de WCAG 2.x (PRUEBAS §5). No se usa una prueba automática.
- TalkBack: la `contentDescription` está declarada y Lint la exige, pero no se escuchó con el lector activo.
