# WelcomeApp — Pruebas y verificación

Qué se verifica, cómo y qué queda fuera. Esta app no tiene lógica: lo que puede fallar son sus **recursos** (textos, traducciones, tamaños, contraste, descripción para TalkBack) y su **ventana** (insets). Por eso la verificación se apoya en Lint, en un cálculo de contraste y en capturas, más que en pruebas unitarias.

| Tipo                       | Cantidad | Resultado                 | Dónde corre            |
| -------------------------- | -------- | ------------------------- | ---------------------- |
| Unitarias (plantilla)      | 1        | En verde                  | JVM                    |
| Instrumentadas (plantilla) | 1        | ⚠ COMPLETAR tras ejecutar | Pixel 7, API 36        |
| Lint                       | —        | 0 errores                 | Build                  |
| Manual con capturas        | 8        | Sección 6                 | Pixel 7 y Pixel Tablet |

---

## 1. Cómo ejecutarlas

```bat
gradlew test
:: Reporte: app/build/reports/tests/testDebugUnitTest/index.html

gradlew connectedDebugAndroidTest
:: Reporte: app/build/reports/androidTests/connected/debug/index.html

gradlew lint
:: Reporte: app/build/reports/lint-results-debug.html
```

---

## 2. Estrategia

| Nivel       | Qué verifica                                                                              | Por qué en ese nivel                                           |
| ----------- | ----------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| **Lint**    | Traducciones completas, descripción de la imagen, pesos eficientes, textos externalizados | Son reglas sobre los recursos, y Lint las revisa en cada build |
| **Cálculo** | Contraste del color de texto (WCAG 2.x)                                                   | Es una fórmula; no necesita dispositivo                        |
| **Manual**  | Tamaño en teléfono y tablet, idioma, modo oscuro, escala de fuente, insets, ícono         | Depende de la configuración real del dispositivo               |

---

## 3. Pruebas automáticas

| Clase                     | Prueba               | Qué verifica                                | Valor para la app                             |
| ------------------------- | -------------------- | ------------------------------------------- | --------------------------------------------- |
| `ExampleUnitTest`         | `addition_isCorrect` | `2 + 2 == 4`                                | Ninguno: solo confirma que JUnit funciona     |
| `ExampleInstrumentedTest` | `useAppContext`      | El paquete es `ec.edu.uta.fisei.welcomeapp` | Confirma el `applicationId` en el dispositivo |

Son las pruebas de ejemplo de la plantilla y se conservan sin cambios. Las pruebas que sí aportarían están propuestas en ANALISIS §7 #13.

---

## 4. Lint como verificación

`gradlew lint` detiene el build ante un error (`abortOnError`, activo por defecto). Que termine en BUILD SUCCESSFUL demuestra que ninguna de estas reglas falla con severidad de error:

| Regla de Lint        | Qué protege en esta app                                  | Relación con el PDF     |
| -------------------- | -------------------------------------------------------- | ----------------------- |
| `MissingTranslation` | Cada texto traducible existe en `values-es`              | 2.8.3–2.8.4, COMPAT #26 |
| `ContentDescription` | La `ImageView` tiene descripción para TalkBack           | 2.7                     |
| `InefficientWeight`  | Los hijos con peso usan `0dp`                            | 2.5.10                  |
| `HardcodedText`      | Ningún texto visible está escrito en el layout           | 2.5.5                   |
| `UnusedResources`    | Recursos sin uso (advertencia; ver ANALISIS §7 #9 y #16) | —                       |

---

## 5. Contraste calculado

Fórmula de WCAG 2.x: `(L_claro + 0,05) / (L_oscuro + 0,05)`, donde `L` es la luminancia relativa del color (sRGB linealizado, con pesos 0,2126 R + 0,7152 G + 0,0722 B).

| Texto                | Fondo                                              | Contraste   | AA texto normal (4,5:1) | AA texto grande (3:1) |
| -------------------- | -------------------------------------------------- | ----------- | ----------------------- | --------------------- |
| `#2196F3` (PDF)      | Blanco                                             | 3,1:1       | No                      | Sí                    |
| `#1565C0` (proyecto) | Blanco                                             | **5,7:1**   | Sí                      | Sí                    |
| `#1565C0` (proyecto) | Fondo oscuro de Material 3 (≈ `#141218`–`#1C1B1F`) | ≈ 3,0–3,2:1 | No                      | En el límite          |

El texto de 40sp cuenta como "texto grande" para WCAG, pero el proyecto buscó cumplir el umbral más estricto en modo claro. Para el modo oscuro, ver ANALISIS §7 #4.

---

## 6. Verificación manual

Cada escenario tiene su captura en `docs/img/`. Las capturas se tomaron con `adb exec-out screencap -p` desde **cmd**; en PowerShell la redirección corrompe el PNG.

| Captura                | Escenario                  | Cómo se prepara                                                     | Qué se comprueba                                                                       |
| ---------------------- | -------------------------- | ------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `01_vertical.png`      | Teléfono, vertical, inglés | Pixel 7, estado por defecto                                         | Mitad y mitad; 40sp; márgenes laterales (ANALISIS §7 #1); nitidez de `bug.png` (§7 #6) |
| `02_horizontal.png`    | Teléfono, horizontal       | `settings put system user_rotation 1`                               | Sigue en 40sp (alto < 600dp); recorte de cámara (§7 #3)                                |
| `03_espanol.png`       | Español                    | `cmd locale set-app-locales … --locales es-ES` o idioma del sistema | `welcome` en español; "WelcomeApp" sin traducir                                        |
| `04_oscuro.png`        | Modo oscuro                | `cmd uimode night yes`                                              | Legibilidad del azul sobre fondo oscuro (§7 #4)                                        |
| `05_fuente_grande.png` | Escala de fuente al 200 %  | `settings put system font_scale 2.0`                                | El texto crece (sp) y si se recorta (§7 #7)                                            |
| `06_tablet.png`        | Tablet                     | Pixel Tablet, API 36                                                | 80sp desde `values-w600dp-h600dp`                                                      |
| `07_icono.png`         | Lanzador                   | Cajón de apps                                                       | Ícono de plantilla (§7 #5)                                                             |
| `08_lint.png`          | Reporte de Lint            | `lint-results-debug.html` en el navegador                           | 0 errores; lista de advertencias (§7 #16)                                              |

---

## 7. Límites conocidos

| Qué no se verifica                        | Motivo                            | Mitigación                                    |
| ----------------------------------------- | --------------------------------- | --------------------------------------------- |
| TalkBack leyendo la descripción           | No se instaló el lector en el AVD | Lint exige `contentDescription` (sección 4)   |
| Contraste en un dispositivo real          | Solo se calculó                   | Fórmula de WCAG; captura del modo oscuro      |
| Recursos por prueba automática            | Las pruebas son las de plantilla  | Lint + capturas; propuesta en ANALISIS §7 #13 |
| Otros idiomas o regiones (`es-419`, etc.) | Fuera del enunciado               | La resolución de API 24+ cae en `values-es`   |

---

## 8. Evolución

| Fase | Commit    | Automáticas       | Verificación agregada                                                                |
| ---- | --------- | ----------------- | ------------------------------------------------------------------------------------ |
| 1    | `9645a98` | 1 + 1 (plantilla) | Compila y ejecuta en el AVD                                                          |
| 2–3  | `ae157f6` | 1 + 1             | Recursos externalizados (`HardcodedText`, `InefficientWeight`, `ContentDescription`) |
| 4    | `2752b7d` | 1 + 1             | Contraste calculado; insets                                                          |
| 5    | `ddb6d79` | 1 + 1             | `MissingTranslation`; 80sp en tablet                                                 |
| fix  | `472d101` | 1 + 1             | `app_name` no traducible                                                             |
| 6    | —         | 1 + 1             | Capturas y documentación                                                             |
