# **Contexto del Proyecto**

Estamos desarrollando una aplicación móvil en Flutter para Control Electoral. Actualmente, la interfaz de usuario (UI) usa componentes Material por defecto y se ve muy genérica.

El objetivo de este prompt es refactorizar la UI hacia un diseño moderno, minimalista, estilo "Soft-UI" / Neumorfismo sutil, con tipografía geométrica limpia y micro-interacciones fluidas.

# **Sistema de Diseño (Design System)**

Por favor, actualiza el archivo lib/core/theme/app\_theme.dart (y los widgets correspondientes) basándote estrictamente en estas reglas:

## **1\. Paleta de Colores**

* **Fondo de la App (Background):** \#F4F5F7 (Un gris azulado muy claro, no usar blanco puro para el fondo de la pantalla).  
* **Superficies (Tarjetas, modales):** \#FFFFFF (Blanco puro).  
* **Color Primario (Azul Noche):** \#0B132B (Para botones principales y headers).  
* **Color Secundario:** \#1C2541  
* **Color de Acento (Ámbar elegante):** \#F59E0B (Para destacar elementos como el "Sobre amarillo", íconos importantes o alertas).  
* **Textos:** Principal \#111827, Secundario/Muted \#6B7280.  
* **Bordes suaves:** \#E5E7EB o \#F1F5F9.

## **2\. Tipografía**

* Utiliza la fuente **Plus Jakarta Sans** (mediante el paquete google\_fonts).  
* Los títulos deben tener un peso grueso (FontWeight.w800 o FontWeight.w900) con un letterSpacing ligeramente ajustado (ej. \-0.5).  
* Los subtítulos o etiquetas (labels) deben usar mayúsculas (UPPERCASE), texto pequeño (10-12px), FontWeight.bold y un letterSpacing amplio (ej. 1.2).

## **3\. Sombras y Bordes (Soft-UI)**

* **Border Radius:** Usa radios grandes. Para botones borderRadius: BorderRadius.circular(16), para tarjetas principales (Cards) usa BorderRadius.circular(24) o 32\.  
* **Sombras (BoxShadow):** EVITA las sombras duras por defecto de Material. Usa sombras amplias, muy transparentes y desplazadas hacia abajo.  
  * *Ejemplo Flutter:* BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: Offset(0, 8))  
* En los TextFields, usa filled: true, fillColor: Colors.grey\[50\] y elimina los bordes oscuros; usa un borde sutil \#E5E7EB y que al hacer focus cambie a \#0B132B.

## **4\. Animaciones y Micro-interacciones (CRÍTICO)**

No quiero vistas estáticas. Implementa las siguientes animaciones usando paquetes como flutter\_animate (recomendado) o controladores nativos:

1. **Fade-in y Slide-up:** Al entrar a una pantalla (como el Login o el Dashboard), los elementos principales deben aparecer deslizando suavemente desde abajo y cambiando su opacidad de 0 a 1\.  
2. **Efecto Cascada (Staggered):** En el listado de mesas (veedor\_home\_page.dart), las tarjetas deben aparecer una tras otra con un retraso (delay) de 100ms entre ellas.  
3. **Escala al presionar:** Crea un widget envoltorio (ej. BouncingButton o ScaleOnTap) usando GestureDetector y AnimatedScale para que CADA tarjeta clickable y CADA botón primario se encoja levemente (a escala 0.98) mientras el usuario mantiene el dedo presionado, simulando el comportamiento de iOS.

# **Tareas para ejecutar:**

1. **Refactorizar app\_theme.dart:** Aplica los colores, tipografía (GoogleFonts.plusJakartaSans) y estilos de Input/ElevatedButton descritos arriba.  
2. **Refactorizar login\_page.dart:**  
   * Quita el AppBar clásico.  
   * Crea un diseño con un logo central.  
   * Usa un contenedor flotante para el formulario.  
   * Aplica el efecto de "escala al presionar" al botón de Login.  
3. **Refactorizar veedor\_home\_page.dart:**  
   * Cambia la tarjeta del listado por una tarjeta estilo *Soft-UI* (blanca, bordes de 24, sombra sutil).  
   * Añade etiquetas de estado redondeadas (Chips) con colores pastel (ej. fondo verde claro, texto verde oscuro para "Completado").  
   * Añade animaciones en cascada al cargar la lista.  
   * Haz que el banner de "Modo Offline" sea flotante o tenga un diseño curvo moderno en la parte superior.  
4. **Diseñar UI de Votación (Acta Form):** Crea o mejora la pantalla de ingreso de votos imitando un menú de ajustes de iOS: tarjetas blancas con filas separadas por líneas sutiles, y un TextField minimalista alineado a la derecha para ingresar los números.

Por favor, genera el código completo paso a paso, asegurándote de no romper la lógica de negocio existente, solo modificando la capa de presentación (UI).