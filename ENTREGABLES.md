# Entregables — Sesión 1 · Wallet UNSAAC

Curso: Desarrollo de Software II (IF616BIN) · 2026-II
Estudiante: Alain Armando Condori Contreras · Código 021501

---

## Qué subir a Google Classroom

1. **Informe en PDF** — se genera desde `INFORME_Sesion01.html` (ver paso 3).
2. **Enlace del repositorio** en GitHub (código fuente).
3. *(Opcional)* **Esquema del código** — `docs/esquema_codigo.html` o `ARQUITECTURA.md`.

---

## Paso 1 — Ejecutar la app

```powershell
cd "C:\Users\User\Desktop\UNSAAC\2026-2\Desarrollo_Software_2\Segunda_Unidad\Sesion01\wallet_unsaac"
flutter run -d chrome --web-browser-flag "--window-size=430,860"
```

Cuando cargue en Chrome, usa `r` para hot reload y `q` para salir.

## Paso 2 — Tomar las capturas (guárdalas en `evidencias/` con ESTOS nombres)

| Archivo | Qué capturar | Cómo lograrlo |
|---------|--------------|---------------|
| `evidencias/01-carga.png` | Spinner de carga (Reto 3) | Para forzarlo, sube la latencia del repo: en `in_memory_wallet_repository.dart` cambia `milliseconds: 350` → `seconds: 4`, recarga y captura. **Revierte luego.** |
| `evidencias/02-principal-claro.png` | Pantalla principal, saldo visible (tema claro) | Estado normal al terminar la carga. |
| `evidencias/03-saldo-oculto.png` | Saldo como `••••••` (Reto 2) | Toca el ícono del ojo. |
| `evidencias/04-tema-oscuro.png` | Misma pantalla en modo oscuro (Reto 1) | Toca el botón de tema hasta llegar a oscuro. |
| `evidencias/05-color-semilla.png` | Paleta cambiada con el selector de color (Reto 4) | Elige otro color semilla. |
| `evidencias/06-error-reintentar.png` | Mensaje de error + botón Reintentar (Reto 3) | Para forzarlo, al inicio de `loadSummary` en el repo agrega `throw Exception('sin conexión');`, recarga y captura. **Revierte luego.** |
| `evidencias/07-flutter-test.png` | *(Opcional)* Terminal con `All tests passed!` | Ejecuta `flutter test`. |

> Captura solo la ventana de la app (no todo el escritorio). En Windows: `Alt + Impr Pant`
> copia la ventana activa, o usa la **Herramienta Recortes** (`Win + Shift + S`).

## Paso 3 — Generar el PDF del informe

1. Abre `INFORME_Sesion01.html` en Chrome (doble clic).
2. Las capturas de `evidencias/` aparecen solas en su lugar; donde falte una, verás un recuadro
   indicando qué pega ahí.
3. `Ctrl + P` → Destino **Guardar como PDF** → Márgenes **Predeterminado** →
   activa **Gráficos de fondo** → Guardar.
4. Súbelo a Classroom como `Informe_Sesion01_Condori.pdf`.

## Paso 4 — Publicar el repositorio (si aún no lo hiciste)

```powershell
git add .
git commit -m "Sesion 1: informe y evidencias"
# crea el repo en GitHub y luego:
git remote add origin https://github.com/<tu-usuario>/wallet_unsaac.git
git push -u origin main
```

Pega la URL resultante en la sección 8 del informe (línea del repositorio).

---

## Lista de verificación final

- [ ] 6 capturas (01–06) en `evidencias/`
- [ ] Cambios temporales de latencia/error **revertidos** en el repositorio de datos
- [ ] `flutter analyze` → *No issues found!*
- [ ] `flutter test` → 22 pruebas en verde
- [ ] Informe exportado a PDF con las capturas visibles
- [ ] URL de GitHub completada en el informe
- [ ] PDF + enlace subidos a Classroom
