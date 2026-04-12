Guía de Construcción: Backend API de AgroForecast en .NET 8
Este documento detalla paso a paso cómo construimos el "cerebro" de la plataforma AgroForecast. Puedes usar este archivo en Google NotebookLM para generar un podcast o video explicativo.

0. Paso a Paso Técnico: Creación del Proyecto
Para los desarrolladores o para el registro técnico, así fue como inicializamos matemáticamente la estructura desde la consola usando la herramienta de comandos de .NET (CLI):

bash
# 1. Crear la solución principal
dotnet new sln -n AgroForecast
# 2. Crear los 4 proyectos de la Arquitectura Limpia
dotnet new webapi -n AgroForecast.API -f net8.0
dotnet new classlib -n AgroForecast.Application -f net8.0
dotnet new classlib -n AgroForecast.Domain -f net8.0
dotnet new classlib -n AgroForecast.Infrastructure -f net8.0
# 3. Agregar los proyectos a la Solución
dotnet sln add AgroForecast.API/AgroForecast.API.csproj AgroForecast.Application/AgroForecast.Application.csproj AgroForecast.Domain/AgroForecast.Domain.csproj AgroForecast.Infrastructure/AgroForecast.Infrastructure.csproj
# 4. Establecer las dependencias (Quién puede ver a quién)
# La API ve la Aplicación y la Infraestructura
dotnet add AgroForecast.API/AgroForecast.API.csproj reference AgroForecast.Application/AgroForecast.Application.csproj AgroForecast.Infrastructure/AgroForecast.Infrastructure.csproj
# La Aplicación ve el Dominio
dotnet add AgroForecast.Application/AgroForecast.Application.csproj reference AgroForecast.Domain/AgroForecast.Domain.csproj
# La Infraestructura ve la Aplicación
dotnet add AgroForecast.Infrastructure/AgroForecast.Infrastructure.csproj reference AgroForecast.Application/AgroForecast.Application.csproj
1. El Concepto: Clean Architecture (Arquitectura Limpia)
Imagina que construyes una casa. No mezclas la tubería del agua con los cables de la luz ni con los muebles de la sala. De la misma manera, en AgroForecast dividimos el servidor en cuatro "capas" o pisos diferentes para que el código sea ordenado, fácil de mantener y probar:

Capa de Dominio (AgroForecast.Domain): Es el corazón del sistema. Aquí definimos "qué" existe en nuestro mundo (ej. Un Producto, un Mercado, un Precio). No le importa si usamos SQL Server, Oracle o Excel. Es pura lógica de negocio.
Capa de Aplicación (AgroForecast.Application): Son las "reglas del juego" y los "Contratos" (Interfaces). Aquí definimos qué acciones podemos hacer (ej. 

IPriceLogRepository
 dice "Debes poder buscar los precios recientes", pero no dice cómo).
Capa de Infraestructura (AgroForecast.Infrastructure): Son las tuercas y tornillos. Aquí es donde le enseñamos al programa a "hablar" específicamente con SQL Server usando una tecnología llamada Entity Framework Core.
Capa de API (AgroForecast.API): Es la puerta principal de la casa. Aquí están los Controladores (Endpoints) que reciben a la Aplicación Móvil, le piden los datos a las capas interiores y se los envuelven en formato ligero (JSON) para enviarlos por internet.
2. Conectando a Base de Datos (Entity Framework Core)
Para que C# entendiera la base de datos que creamos antes en SQL Server, hicimos lo siguiente:

Instalamos las librerías necesarias con el comando: dotnet add package Microsoft.EntityFrameworkCore.SqlServer -v 8.0.10
Configuramos la cadena de conexión en el archivo principal 

appsettings.json
 de la API para apuntar a la base local ("ConnectionStrings": {"DefaultConnection": "Server=localhost;Database=AgroForecastDB;Trusted_Connection=True;"}).
Creamos una clase gigante de mapeo llamada 

AppDbContext
 dentro de Infraestructura (

Infrastructure/Data/AppDbContext.cs
). Esta clase toma cada tabla en SQL (ej: Products) y le enseña a .NET cómo usarla como una lista en memoria (DbSet<Product>).
Finalmente fuimos a 

Program.cs
 y le dijimos a la aplicación que "Prenda el motor" de bases de datos al momento de iniciar (builder.Services.AddDbContext<AppDbContext>(...)).
3. Creando los Repositorios (El patrón Repository)
En lugar de que la "Puerta Principal" (API) vaya y busque los datos directamente a la caja fuerte (Base de datos), creamos un empleado especializado llamado 

PriceLogRepository
.

La API le pide los precios de la papa a este empleado, y el empleado sabe exactamente cómo ir a la base de datos de manera eficiente, ordenarlos por fecha y traer solo los últimos 30 días para no saturar el celular del usuario.

4. Los Endpoints (Controladores para el celular)
Finalmente, expusimos la información al mundo exterior (a la futura app de Flutter/React Native). Creamos el archivo 

PricesController.cs
 con métodos [HttpGet].

TIP

El Secreto del DTO (Data Transfer Object): Nunca debemos enviar la clase "pura" de la base de datos al teléfono móvil por seguridad e ineficiencia. En su lugar creamos una clase simplificada (

PriceLogDto
). El servidor toma la información pesada de la base de datos, la empaca en esta caja ligera llamada DTO y esa es la cajita que viaja por internet hasta el celular del chef del restaurante.

Actualmente, construimos Endpoints como:

GET /api/prices/product/1: Para ver el historial reciente y dibujar gráficas en la app.
GET /api/prices/product/1/market/2/latest: Para ver cuál fue el último precio reportado hoy.
5. Desafíos Superados y Lecciones Aprendidas (Para el Podcast)
Para darle un toque de realidad y emoción al resumen de NotebookLM, aquí hay tres retos técnicos reales que resolvimos exitosamente durante la conexión del Backend:

El Misterio de la Conexión a la Base de Datos (Error 40 - Named Pipes): Al principio, nuestra API no podía "ver" la base de datos local usando el nombre genérico localhost. Descubrimos que SQL Server Express requiere que se le asigne su nombre de instancia exacto. Tuvimos que explorar hasta encontrar la ruta estricta del servidor en tu máquina (NESTORZ13\SQLEXPRESS) y colocarla en el archivo de configuración 

appsettings.json
. ¡Y se hizo la luz!

El Problema del producto "Desconocido" (Lazy Loading vs Eager Loading): Cuando le pedimos los precios a la API por primera vez, nos devolvía los valores correctamente, pero los nombres de los productos y mercados decían "Desconocido". Esto es porque la tecnología Entity Framework Core por defecto es ahorrativa y "perezosa" (Lazy Loading) y no consulta tablas anexas para ahorrar memoria. ¿La solución analítica? Le agregamos la instrucción .Include(p => p.Product) a nuestro código del Repositorio para obligarlo a hacer un Eager Loading exhaustivo y traer la información relacional completa.

Abriendo las Puertas al Front-End (Políticas CORS): Cuando fuimos a conectar nuestra flamante App Móvil construida en Flutter con el Backend, el navegador Chrome las bloqueó abruptamente por seguridad ("Política de CORS"). Tuvimos que ir al archivo principal 

Program.cs
 del Backend y enseñarle explícitamente a confiar en nuestra aplicación web de Flutter habilitando reglas de CORS (Cross-Origin Resource Sharing). Tuvimos un muy leve tropiezo de sintaxis en el código que hizo que la API se negara a arrancar, pero lo depuramos rápidamente y los datos lograron fluir por la red.