# WelcomeApp — Análisis de diseño (PDF Deitel 2016 → Kotlin / API 36)

Este documento complementa a [COMPATIBILIDAD.md](COMPATIBILIDAD.md):

- **COMPATIBILIDAD.md** responde _qué cambió porque Android cambió_.
- **Este documento** responde _qué principios aplican a una app sin lógica_, qué errores tiene el libro y qué no resuelve el proyecto.

> **Convenciones**
>
> - `PDF 2.5.6`, `Fig. 2.12 l. 6`: sección, figura y línea del libro (cap. 2).
> - Las rutas son relativas a `app/src/main/`.
> - `COMPAT #n` remite a una fila de COMPATIBILIDAD.md.
> - Toda afirmación sobre el proyecto se puede verificar con los comandos de la sección 8.
> - **Código congelado desde la fase 6:** lo que falla se documenta aquí y no se corrige.

---

## 1. Resumen

| Métrica               | PDF                                  | Proyecto                                                    |
| --------------------- | ------------------------------------ | ----------------------------------------------------------- |
| Código escrito a mano | Ninguno ("sin escribir código", 2.9) | `ui/welcome/MainActivity.kt`, unas 30 líneas (edge-to-edge) |
| Lógica de negocio     | Ninguna                              | Ninguna                                                     |
| Layout                | 1 (`activity_main.xml`)              | 1 (`activity_main.xml`)                                     |
| Recursos alternativos | `values-es`, `values-w600dp-h600dp`  | Los mismos, más `values-night`                              |
| Pruebas               | 0                                    | 2, las de ejemplo de la plantilla                           |
| Lint                  | —                                    | 0 errores (`gradlew lint` termina en BUILD SUCCESSFUL)      |

Welcome no tiene comportamiento: muestra un texto y una imagen. Por eso **el diseño de esta práctica se juzga por sus recursos** (externalización, recursos alternativos, unidades, accesibilidad), no por sus clases. La sección 2 responde si se aplicó arquitectura limpia y la sección 7 documenta lo que el proyecto no resuelve.

---

## 2. ¿Se aplicó arquitectura limpia?

**Se creó la estructura, pero no tiene contenido, y eso es lo correcto.**

```
ec.edu.uta.fisei.welcomeapp
├── core/                  .gitkeep
├── data/repository/       .gitkeep
├── domain/model/          .gitkeep
├── domain/repository/     .gitkeep
├── domain/usecase/        .gitkeep
└── ui/welcome/            .gitkeep + MainActivity.kt
```

- Las carpetas vienen del commit `56518d4` ("estructura de paquetes") y son las mismas capas que usa P05 Doodlz (`core`, `domain`, `data`, `ui`).
- Ninguna capa tiene código, porque no hay reglas que aislar: no hay datos, estado ni casos de uso. Crear un `WelcomeViewModel` o un `GetWelcomeMessageUseCase` violaría YAGNI y KISS (sección 5).
- La regla de dependencias `ui → domain ← data` se cumple, pero **de forma vacía**: `git grep` no encuentra importaciones de Android en `domain` porque `domain` no tiene archivos. Eso no demuestra ninguna calidad de diseño.
- El archivo `ui/welcome/.gitkeep` sobra, porque la carpeta ya contiene `MainActivity.kt`.

**Decisión:** se mantienen las carpetas como plantilla común del curso, y queda documentado que están vacías a propósito (§7 #12).

---

## 3. Malos olores (STUPID)

| Letra | Olor                   | ¿Presente? | Comentario                                                                                                         |
| ----- | ---------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------ |
| **S** | Singleton              | No aplica  | No hay estado global                                                                                               |
| **T** | Tight coupling         | No aplica  | Una sola clase; el layout no conoce a la Activity                                                                  |
| **U** | Untestability          | No aplica  | No hay lógica que probar. Lo verificable son los recursos (PRUEBAS)                                                |
| **P** | Premature optimization | No aplica  | El `layout_height="0dp"` con peso es la recomendación de Lint (`InefficientWeight`), no una optimización prematura |
| **I** | Indescriptive naming   | No         | `welcomeTextView`, `bugImageView`, `welcome_textsize`: nombres del PDF, descriptivos y con unidad implícita        |
| **D** | Duplication            | **Leve**   | `values-night/themes.xml` es una copia idéntica de `values/themes.xml` (§7 #10)                                    |

---

## 4. Principios SOLID

SOLID trata sobre cómo repartir responsabilidades entre clases. Con una clase de unas 30 líneas no hay decisiones SOLID que evaluar:

| Principio | Evaluación                                                                                                                                                                     |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **S**     | Se cumple: `MainActivity` solo configura la ventana (edge-to-edge e insets). El contenido viene del layout y los recursos                                                      |
| **O**     | Se cumple a nivel de recursos: un idioma o un tamaño de pantalla nuevo es una carpeta `values-*` nueva, sin tocar código. Es la aplicación más clara del principio en esta app |
| **L**     | No aplica: no hay jerarquías propias                                                                                                                                           |
| **I**     | No aplica: no hay interfaces propias                                                                                                                                           |
| **D**     | No aplica: no hay dependencias que invertir                                                                                                                                    |

---

## 5. Otros principios aplicados

| Principio                                    | Evidencia                                                                                                                                                                           |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Externalizar recursos** (PDF 2.2.4, 2.5.5) | Texto, descripción, tamaño y color salen de `strings.xml`, `dimens.xml` y `colors.xml`. Excepción: `padding="16dp"` literal (§7 #1)                                                 |
| **Recursos alternativos**                    | `values-es` (idioma) y `values-w600dp-h600dp` (tamaño): Android elige sin código. Mismo nombre de recurso en cada carpeta (PDF 2.5.6, paso 2)                                       |
| **Unidades correctas**                       | `sp` para el texto (respeta la escala de fuente del usuario) y `dp` para el espaciado (PDF 2.5.6)                                                                                   |
| **Accesibilidad**                            | `contentDescription` traducida; contraste 5,7:1 sobre blanco (COMPAT #14)                                                                                                           |
| **KISS**                                     | `LinearLayout` con dos pesos iguales expresa directamente "mitad y mitad"; no hace falta `ConstraintLayout`                                                                         |
| **YAGNI**                                    | Sin ViewModel, sin inyección de dependencias ni casos de uso. Pendientes que lo contradicen: `constraintlayout` sin uso (§7 #8), colores sin uso (§7 #9) y carpetas vacías (§7 #12) |
| **Trazabilidad con el libro**                | Los ids y nombres de recursos son los del PDF                                                                                                                                       |

---

## 6. Errores e inconsistencias del PDF

### 6.1 Errores en el texto

| #   | Ubicación              | Qué dice el PDF                                                                                                                                                                                                             | Lo correcto                                                                                                                                                                                       |
| --- | ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | PDF 2.5.6, pasos 5 y 6 | El paso 5 crea una carpeta `values-xlarge`; el paso 6 marca `values-w600dp-h600dp`                                                                                                                                          | La carpeta creada es `values-w600dp-h600dp`. `xlarge` es un calificador de tamaño distinto y obsoleto (COMPAT #19). El texto habla además de "pantallas extra grandes", mezclando ambos conceptos |
| 2   | PDF 2.4.6              | "La GUI por defecto de una app **Blank Page**"                                                                                                                                                                              | La plantilla elegida en 2.3.5 fue **Empty Activity**                                                                                                                                              |
| 3   | PDF 2.2.3              | Android Studio analiza el XML para "generar el código Java que produce la GUI"                                                                                                                                              | El layout no se traduce a Java: se infla en tiempo de ejecución. Lo que se genera es la clase `R` con los ids                                                                                     |
| 4   | Fig. 2.6               | Anuncia "cuatro plantillas de uso común"                                                                                                                                                                                    | La tabla describe tres (Blank, Fullscreen, Master/Detail), y no incluye Empty Activity, que es la que se usa                                                                                      |
| 5   | PDF 2.7 (título) y 2.9 | "TalkBack para los **ImageViews**", "las cadenas de accesibilidad de los ImageViews"                                                                                                                                        | La app tiene **un** ImageView                                                                                                                                                                     |
| 6   | PDF 2.9                | El texto usa "uno de los colores estándar del tema"                                                                                                                                                                         | En 2.5.7 se crea un recurso de color propio (`#2196F3`), no un color del tema                                                                                                                     |
| 7   | Fig. 2.10 vs PDF 2.5.2 | La carpeta `mipmap` "se verá más adelante en el libro"                                                                                                                                                                      | Se usa en el mismo capítulo, en 2.5.2, para el ícono                                                                                                                                              |
| 8   | Fig. 2.20              | Lista px, dp/dip, sp, in y mm                                                                                                                                                                                               | Omite `pt` (puntos), que Android también acepta                                                                                                                                                   |
| 9   | PDF 2.4.5              | "Android devices can run on many types of devices"                                                                                                                                                                          | Frase sin sentido; debería decir que Android se ejecuta en muchos tipos de dispositivos                                                                                                           |
| 10  | Varias                 | "highe-resolution" (Obs. 2.1), "every versions" (2.5.2), "be selecting" (2.5.12), "views's" (2.7), "it's nested" (2.4.1), "changethe" (2.5.4), "introduccion" sin tilde (2.8.6); 2.5.1 habla de "the images" y solo hay una | Erratas                                                                                                                                                                                           |

### 6.2 Problemas de diseño en lo que enseña el libro

Solo los que **no** están en COMPATIBILIDAD.md.

| #   | Ubicación          | Problema                                                                                                                                           | Efecto                                                                                                                | En el proyecto         |
| --- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| A   | PDF 2.5.6 + 2.5.10 | El texto crece con la escala de fuente (`sp`), pero su altura está fija a la mitad de la pantalla (`weight`), sin desplazamiento ni `autoSizeText` | Con escalas de fuente grandes el texto puede recortarse                                                               | Heredado → §7 #7       |
| B   | PDF 2.5.1          | Una sola versión de `bug.png`, en `drawable/` sin calificador (se interpreta como mdpi)                                                            | En pantallas de 420dpi Android la amplía unas 2,6 veces y puede verse borrosa. El propio libro lo advierte (Obs. 2.1) | Heredado → §7 #6       |
| C   | PDF 2.8.4          | Decide no traducir `app_name`, pero no lo marca como no traducible                                                                                 | Hoy Lint lo trata como error (`MissingTranslation`)                                                                   | Corregido (COMPAT #26) |

### 6.3 Ya documentados en COMPATIBILIDAD.md

Contraste de `#2196F3` (#14), barras opacas frente a edge-to-edge (#15), ícono PNG frente a adaptativo (#18), Custom Locale (#24) y TalkBack en AVD (#23).

---

## 7. Autocrítica: deuda técnica conocida

El código está congelado. Cada punto indica cómo se verifica; los marcados **Sin verificar** se confirman con la captura indicada (PRUEBAS §6).

| #   | Hallazgo                                                                                                                                                                                      | Riesgo                                                                                                                                                   | Acción propuesta                                                                                                                     | Estado                               |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------ |
| 1   | `MainActivity` llama a `updatePadding(bars…)`, que **reemplaza** el `padding="16dp"` del layout. Además, ese 16dp está escrito literalmente, no como `@dimen`                                 | En vertical los márgenes laterales quedan en 0 y el texto de 40sp llega al borde                                                                         | Guardar el padding inicial y sumarle los insets; mover 16dp a `dimens.xml`                                                           | Pendiente · captura 01               |
| 2   | `android:fitsSystemWindows="true"` en el mismo view que tiene un `OnApplyWindowInsetsListener`, más `tools:ignore="EdgeToEdgeOverlay"`                                                        | Configuración confusa: el listener sustituye el manejo por defecto, así que el atributo no tiene efecto. La supresión puede ocultar una advertencia útil | Quitar el atributo y la supresión, y dejar solo el listener                                                                          | Pendiente                            |
| 3   | Los insets solo incluyen `systemBars()`, no `displayCutout()`                                                                                                                                 | En horizontal, el contenido puede quedar bajo el recorte de la cámara                                                                                    | Usar `systemBars() or displayCutout()`                                                                                               | Sin verificar · captura 02           |
| 4   | `#1565C0` también se usa en modo oscuro (`values-night` no redefine el color)                                                                                                                 | Contraste de unos 3:1 sobre el fondo oscuro de Material 3: justo en el mínimo AA para texto grande y por debajo del de texto normal                      | `values-night/colors.xml` con un azul claro (por ejemplo, Blue 200)                                                                  | Pendiente · captura 04               |
| 5   | El ícono es el de la plantilla. Además, las capas `drawable/ic_launcher_background.xml` y `ic_launcher_foreground.xml` existen, pero no hay `mipmap-anydpi(-v26)/ic_launcher.xml` que las use | No se cumplió el paso 2.5.2 del PDF; hay recursos huérfanos y el lanzador usa los PNG heredados                                                          | Image Asset con el logo del curso, que genera el ícono adaptativo completo                                                           | Pendiente · captura 07               |
| 6   | `bug.png` sin calificador de densidad                                                                                                                                                         | Imagen ampliada en alta densidad (§6.2 B)                                                                                                                | Moverla a `drawable-nodpi` o proveer versiones por densidad                                                                          | Sin verificar · captura 01           |
| 7   | Texto de altura fija con tamaño en `sp` (§6.2 A)                                                                                                                                              | Recorte con fuente grande                                                                                                                                | Permitir desplazamiento o usar `autoSizeTextType`                                                                                    | Sin verificar · captura 05           |
| 8   | `constraintlayout` declarado y ningún layout lo usa                                                                                                                                           | Dependencia sin uso (YAGNI), igual que en P05                                                                                                            | Quitarla del build y del catálogo                                                                                                    | Pendiente                            |
| 9   | `R.color.black` y `R.color.white` sin uso                                                                                                                                                     | Advertencia `UnusedResources`                                                                                                                            | Borrarlos de `colors.xml`                                                                                                            | Pendiente                            |
| 10  | `values-night/themes.xml` idéntico al tema claro                                                                                                                                              | Duplicación sin efecto (DayNight ya cambia solo)                                                                                                         | Borrarlo hasta que haya algo que personalizar                                                                                        | Pendiente                            |
| 11  | `windowSoftInputMode="adjustResize"` en una pantalla sin campos de texto                                                                                                                      | Configuración de plantilla sin propósito                                                                                                                 | Quitarlo                                                                                                                             | Pendiente                            |
| 12  | Paquetes `core`, `domain` y `data` vacíos con `.gitkeep` (§2)                                                                                                                                 | Sugieren una arquitectura que no existe                                                                                                                  | —                                                                                                                                    | Aceptado: convención común del curso |
| 13  | Las pruebas son las de plantilla (`2 + 2 = 4` y el nombre del paquete)                                                                                                                        | No verifican nada propio de la app                                                                                                                       | Prueba instrumentada de recursos (texto, `contentDescription`, 40sp/80sp) y prueba de contraste como `BrandColorContrastTest` de P05 | Aceptado para el alcance             |
| 14  | Sin `localeConfig`                                                                                                                                                                            | La app no aparece en "Idioma de la app" de Android 13+                                                                                                   | `generateLocaleConfig` en AGP                                                                                                        | Opcional (fuera del PDF)             |
| 15  | TalkBack no se probó con el lector activo                                                                                                                                                     | La descripción existe, pero no se escuchó                                                                                                                | Instalar Android Accessibility Suite en el AVD y recorrer la pantalla                                                                | Sin verificar                        |
| 16  | Las advertencias de Lint no se revisaron una por una                                                                                                                                          | Se sabe que hay 0 errores, pero no se conoce el total de advertencias                                                                                    | Revisar `app/build/reports/lint-results-debug.html` (captura 08)                                                                     | Pendiente                            |

---

## 8. Cómo verificar este documento

```bat
:: 0 errores de Lint y pruebas de plantilla en verde
gradlew test lint

:: §2: las capas solo contienen .gitkeep
git ls-files "app/src/main/java/*.gitkeep"

:: §7 #5: no existe el ícono adaptativo (debe decir "File Not Found")
dir app\src\main\res\mipmap-anydpi*

:: §7 #8: nadie usa ConstraintLayout (no debe imprimir nada)
git grep -n "ConstraintLayout" -- app/src

:: §7 #9: black y white solo aparecen en su definición
git grep -n "color/black\|color/white\|R.color" -- app/src

:: §7 #10: los temas claro y oscuro difieren solo en los comentarios
git diff --no-index app/src/main/res/values/themes.xml app/src/main/res/values-night/themes.xml
```
