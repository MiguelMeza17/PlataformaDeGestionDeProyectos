using System;
using System.IO;
using System.Linq;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders;
using Microsoft.AspNetCore.Http;
using GestionDeProyectos.pkgDomain;
using GestionDeProyectos.pkgUI;

#nullable disable

var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    ContentRootPath = AppContext.BaseDirectory
});

builder.Services.AddCors(options => {
    options.AddDefaultPolicy(policy => {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.ConfigureHttpJsonOptions(options => {
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter());
});

var app = builder.Build();
app.UseCors();

string proyectoRaiz = Directory.GetCurrentDirectory(); 
string rutaPkgUI = Path.Combine(proyectoRaiz, "pkgUI");

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(rutaPkgUI),
    RequestPath = "/pkgUI" 
});

app.MapPost("/api/login", (LoginDTO datos) => {
    try 
    {
        var controlador = clsController.opGetInstance();
        var usuario = controlador.opLoginStakeholder(datos.nombre, datos.password);

        if (usuario != null) {
            return Results.Ok(new {
                nombre = usuario.opGetName(),
                rolId = (int)usuario.opGetRol(),
                id = usuario.opGetOUID()
            });
        }
        return Results.Json(new { mensaje = "Usuario o contraseña incorrectos" }, statusCode: 401);
    }
    catch (Exception ex) 
    {
        return Results.Problem("Error interno en el login: " + ex.Message);
    }
});

app.MapPost("/api/registrar", (UsuarioRegistroDTO datos) => {
    try 
    {
        var controlador = clsController.opGetInstance();

        if (!Enum.TryParse(datos.rol, out clsRoles rolEnum))
        {
            return Results.BadRequest(new { mensaje = "El rol proporcionado no es válido." });
        }

        bool exito = controlador.opRegisterStakeholder(
            datos.nombre, 
            "Registro desde Web", 
            datos.email, 
            datos.password, 
            rolEnum 
        );

        if (exito) {
            return Results.Ok(new { mensaje = "Usuario guardado con éxito" });
        } else {
            return Results.BadRequest(new { mensaje = "El usuario ya existe o hubo un error" });
        }
    }
    catch (Exception ex) 
    {
        return Results.Problem("Error interno: " + ex.Message);
    }
});

app.MapGet("/api/usuarios", (string email) => {
    try
    {
        if (string.IsNullOrEmpty(email))
        {
            return Results.BadRequest(new { mensaje = "El parámetro email es requerido." });
        }

        var controlador = clsController.opGetInstance();
        var usuario = controlador.opGetStakeholder(0, email);

        if (usuario == null)
        {
            return Results.NotFound(new { mensaje = "Usuario no encontrado." });
        }

        return Results.Ok(new {
            id = usuario.opGetOUID(),
            nombre = usuario.opGetName(),
            descripcion = usuario.opGetDescription(),
            email = usuario.opGetEmail(),
            password = usuario.opGetPassword(),
            rol = (int)usuario.opGetRol()
        });
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al buscar usuario: " + ex.Message);
    }
});

app.MapPut("/api/usuarios/{id:int}", (int id, UsuarioActualizarDTO datos) => {
    try
    {
        if (id != datos.prmOUID)
        {
            return Results.BadRequest(new { mensaje = "El ID de la ruta no coincide con el del cuerpo." });
        }

        var controlador = clsController.opGetInstance();
        bool exito = controlador.opUpdateStakeholder(
            datos.prmOUID,
            datos.prmName,
            datos.prmDescription,
            datos.prmEmail,
            datos.prmPassword,
            (clsRoles)datos.prmRol
        );

        if (exito)
        {
            return Results.Ok(new { mensaje = "✅ Usuario actualizado correctamente en la base de datos y en memoria." });
        }
        else
        {
            return Results.BadRequest(new { mensaje = "❌ No se pudo actualizar el usuario. Verifique los datos." });
        }
    }
    catch (Exception ex)
    {
        return Results.Problem("Error interno al actualizar usuario: " + ex.Message);
    }
});

app.MapGet("/api/proyectos/listar", () => {
    try
    {
        var vrmController = clsController.opGetInstance();
        var vrmListaProyectos = vrmController.opListAllProjects();
        return Results.Ok(vrmListaProyectos);
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al listar proyectos: " + ex.Message);
    }
});

app.MapPost("/api/proyectos/crear", (clsCrearProyectoDTO prmDatos) => {
    try
    {
        var vrmController = clsController.opGetInstance();
        bool vrmExito = vrmController.opRegisterProject(
            0, 
            prmDatos.nombre,
            prmDatos.descripcion,
            prmDatos.fechaInicio,
            prmDatos.fechaFinalizacion,
            prmDatos.estadoGeneral,
            prmDatos.porcentajeAvance
        );

        if (vrmExito)
            return Results.Ok(new { mensaje = "✅ Proyecto registrado exitosamente en la base de datos." });
        else
            return Results.BadRequest(new { mensaje = "❌ Error al registrar el proyecto. Verifique duplicados." });
    }
    catch (Exception ex)
    {
        return Results.Problem("Error interno al crear proyecto: " + ex.Message);
    }
});

app.MapPut("/api/proyectos/actualizar", (clsActualizarProyectoDTO prmDatos) => {
    try
    {
        var vrmController = clsController.opGetInstance();
        bool vrmExito = vrmController.opUpdateProject(
            prmDatos.idProyecto,
            prmDatos.nombre,
            prmDatos.descripcion,
            prmDatos.fechaInicio,
            prmDatos.fechaFinalizacion,
            prmDatos.estadoGeneral,
            prmDatos.porcentajeAvance
        );

        if (vrmExito)
            return Results.Ok(new { mensaje = "✅ Proyecto actualizado correctamente en la base de datos." });
        else
            return Results.BadRequest(new { mensaje = "❌ No se pudo actualizar el proyecto. Verifique el ID." });
    }
    catch (Exception ex)
    {
        return Results.Problem("Error interno al actualizar proyecto: " + ex.Message);
    }
});

app.MapDelete("/api/proyectos/eliminar/{id:int}", (int id) => {
    try
    {
        var vrmController = clsController.opGetInstance();
        bool vrmExito = vrmController.opDeleteProject(id);

        if (vrmExito)
            return Results.Ok(new { mensaje = "✅ Proyecto eliminado correctamente de la base de datos." });
        else
            return Results.BadRequest(new { mensaje = "❌ No se pudo eliminar el proyecto." });
    }
    catch (Exception ex)
    {
        return Results.Problem("Error interno al eliminar proyecto: " + ex.Message);
    }
});
// ==============================================================================
// 🌟 NUEVO: ENDPOINTS PARA REPORTES ANALÍTICOS (CONSULTAS SQLITE)
// ==============================================================================

app.MapGet("/api/reportes/listar", () => {
    try
    {
        var vrmController = clsController.opGetInstance();
        var vrmDatos = vrmController.opGetReporteListarProyectos();
        return Results.Ok(vrmDatos);
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al generar reporte de listado: " + ex.Message);
    }
});

app.MapGet("/api/reportes/conteo", () => {
    try
    {
        var vrmController = clsController.opGetInstance();
        var vrmDatos = vrmController.opGetReporteConteoReportes();
        return Results.Ok(vrmDatos);
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al generar reporte de conteo: " + ex.Message);
    }
});

app.MapGet("/api/reportes/promedio", () => {
    try
    {
        var vrmController = clsController.opGetInstance();
        var vrmDatos = vrmController.opGetReportePromedioAvance();
        return Results.Ok(vrmDatos);
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al generar reporte de promedios: " + ex.Message);
    }
});
app.MapPost("/api/reportes/crear", (clsCrearReporteDTO prmDatos) =>
{
    try
    {
        var vrmController = clsController.opGetInstance();

        bool vrmExito = vrmController.opRegisterReport(
    prmDatos.idProyecto,
    0,
    prmDatos.nombre,
    prmDatos.descripcion,
    prmDatos.fecha,
    prmDatos.resumenAvance,
    prmDatos.tareasRetrasadas
        );

        if (vrmExito)
        {
            return Results.Ok(new
            {
                mensaje = "Reporte registrado correctamente."
            });
        }

        return Results.BadRequest(new
        {
            mensaje = "No fue posible registrar el reporte."
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(
            "Error al registrar reporte: " + ex.Message
        );
    }
});

app.MapPost("/api/tareas", (TareaRegistroDTO nuevaTarea) => {
    try
    {
        var controlador = clsController.opGetInstance();
        
        clsState estadoEnum = clsState.ToDevelop;

        bool exito = controlador.opRegisterTask(
            0,
            nuevaTarea.nombre,
            nuevaTarea.descripcion,
            nuevaTarea.fechaInicio,
            nuevaTarea.fechaLimite,
            estadoEnum,
            nuevaTarea.idProyecto,
            nuevaTarea.idUsuarioAsigna,
            nuevaTarea.idUsuarioDesarrolla
        );

        if (exito)
        {
            return Results.Ok(new { mensaje = "✅ Tarea registrada con éxito" });
        }
        else
        {
            return Results.BadRequest(new { mensaje = "❌ No se pudo registrar la tarea. Verifique si ya existe." });
        }
    }
    catch (Exception ex)
    {
        return Results.Problem("Error interno en el servidor: " + ex.Message);
    }
});

app.MapGet("/api/usuarios/desarrolladores", () => {
    try
    {
        var controlador = clsController.opGetInstance();
        var desarrolladores = controlador.opListDevelopers();
        
        var listaDto = desarrolladores.Select(dev => new DesplegableDeveloperDTO(
            dev.opGetOUID(),
            dev.opGetName()
        )).ToList();

        return Results.Ok(listaDto);
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al obtener desarrolladores: " + ex.Message);
    }
});

app.MapGet("/api/tareas/desarrollador/{id:int}", (int id) => {
    try
    {
        var controlador = clsController.opGetInstance();
        var tareasDominio = controlador.opListTasksByDeveloper(id);

        if (tareasDominio == null) return Results.NotFound();

        var listadoTareas = tareasDominio.Select(t => new {
            id = t.opGetOUID(),
            nombre = t.opGetName(),
            descripcion = t.opGetDescription(),
            fechaLimite = t.opGetLimitDate(),
            estado = t.opGetState().ToString()
        }).ToList();

        return Results.Ok(listadoTareas);
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al listar tareas del desarrollador: " + ex.Message);
    }
});

// ENDPOINT CORREGIDO: Mapeo nativo por DTO para romper el bucle del error 400
app.MapPut("/api/tareas/{id:int}/estado", (int id, EstadoTareaDTO datos) => {
    try
    {
        if (datos == null)
        {
            return Results.BadRequest(new { mensaje = "❌ El cuerpo de la petición está vacío o mal estructurado." });
        }

        // Ejecuta directo la consulta en la base de datos SQLite
        bool exitoDb = GestionDeProyectos.pkgData.clsTaskData.opActualizarEstadoTarea(id, datos.nuevoEstado);

        if (exitoDb)
        {
            // Sincroniza el estado en el objeto de la memoria local
            clsState estadoEnum = (clsState)datos.nuevoEstado;
            var controlador = clsController.opGetInstance();
            
            var tareaEnMemoria = controlador.opGetTask(id, null);
            if (tareaEnMemoria != null)
            {
                tareaEnMemoria.opModifyState(estadoEnum);
            }

            return Results.Ok(new { mensaje = "✅ Estado de la tarea actualizado con éxito en la base de datos y memoria." });
        }
        else
        {
            return Results.BadRequest(new { mensaje = "❌ La base de datos no pudo procesar el cambio. Verifica si el ID existe en la base de datos." });
        }
    }
    catch (Exception ex)
    {
        return Results.Problem("Error al actualizar el estado de la tarea: " + ex.Message);
    }
});

// ==========================================
// ARRANQUE DEL SERVIDOR
// ==========================================

Console.WriteLine("Servidor iniciado en http://localhost:5000");
app.Run("http://localhost:5000");

// ==========================================
// OBJETOS DE TRANSFERENCIA DE DATOS (DTOs)
// ==========================================
public record clsCrearReporteDTO(
    int idProyecto,
    string nombre,
    string descripcion,
    DateTime fecha,
    string resumenAvance,
    int tareasRetrasadas
);
public record LoginDTO(string nombre, string password);
public record UsuarioRegistroDTO(string nombre, string email, string password, string rol);
public record UsuarioActualizarDTO(int prmOUID, string prmName, string prmDescription, string prmEmail, string prmPassword, int prmRol);

public record clsCrearProyectoDTO(string nombre, string descripcion, DateTime fechaInicio, DateTime fechaFinalizacion, string estadoGeneral, float porcentajeAvance);
public record clsActualizarProyectoDTO(int idProyecto, string nombre, string descripcion, DateTime fechaInicio, DateTime fechaFinalizacion, string estadoGeneral, float porcentajeAvance);
public record TareaRegistroDTO(string nombre, string descripcion, DateTime fechaInicio, DateTime fechaLimite, int idProyecto, int idUsuarioAsigna, int idUsuarioDesarrolla, string estado);
public record DesplegableDeveloperDTO(int id, string nombre);

// NUEVO DTO: Asegura que el JSON entrante se capture automáticamente
public record EstadoTareaDTO(int nuevoEstado);