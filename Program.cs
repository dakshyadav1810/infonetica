using InfoneticaWorkflowEngine.Services;
using InfoneticaWorkflowEngine.Stores;
using InfoneticaWorkflowEngine.Payloads;
using InfoneticaWorkflowEngine.Models;

var builder = WebApplication.CreateBuilder(args);

// Register services
builder.Services.AddSingleton<IBlueprintStore, InMemoryBlueprintStore>();
builder.Services.AddSingleton<IRunningWorkflowStore, InMemoryRunningWorkflowStore>();
builder.Services.AddScoped<IWorkflowOrchestrator, WorkflowOrchestrator>();

var app = builder.Build();

// Blueprint endpoints
app.MapPost("/blueprints", (CreateBlueprintPayload payload, IWorkflowOrchestrator orchestrator) =>
{
    try
    {
        var blueprint = orchestrator.CreateBlueprint(payload);
        return Results.Created($"/blueprints/{blueprint.Id}", blueprint);
    }
    catch (ArgumentException ex)
    {
        return Results.BadRequest(new { error = ex.Message });
    }
    catch (Exception ex)
    {
        return Results.Problem(ex.Message);
    }
});

app.MapGet("/blueprints", (IWorkflowOrchestrator orchestrator) =>
{
    var blueprints = orchestrator.GetAllBlueprints();
    return Results.Ok(blueprints);
});

app.MapGet("/blueprints/{id}", (string id, IWorkflowOrchestrator orchestrator) =>
{
    var blueprint = orchestrator.GetBlueprint(id);
    return blueprint != null ? Results.Ok(blueprint) : Results.NotFound();
});

// Workflow endpoints
app.MapPost("/workflows", (StartWorkflowPayload payload, IWorkflowOrchestrator orchestrator) =>
{
    try
    {
        var workflow = orchestrator.StartWorkflow(payload);
        return Results.Created($"/workflows/{workflow.Id}", workflow);
    }
    catch (ArgumentException ex)
    {
        return Results.BadRequest(new { error = ex.Message });
    }
    catch (InvalidOperationException ex)
    {
        return Results.Conflict(new { error = ex.Message });
    }
    catch (Exception ex)
    {
        return Results.Problem(ex.Message);
    }
});

app.MapGet("/workflows", (IWorkflowOrchestrator orchestrator) =>
{
    var workflows = orchestrator.GetAllRunningWorkflows();
    return Results.Ok(workflows);
});

app.MapGet("/workflows/{id}", (string id, IWorkflowOrchestrator orchestrator) =>
{
    var workflow = orchestrator.GetRunningWorkflow(id);
    return workflow != null ? Results.Ok(workflow) : Results.NotFound();
});

app.MapPost("/workflows/{workflowId}/execute", (string workflowId, ExecuteActionOnWorkflowPayload payload, IWorkflowOrchestrator orchestrator) =>
{
    try
    {
        var workflow = orchestrator.ExecuteAction(workflowId, payload);
        return Results.Ok(workflow);
    }
    catch (ArgumentException ex)
    {
        return Results.BadRequest(new { error = ex.Message });
    }
    catch (InvalidOperationException ex)
    {
        return Results.Conflict(new { error = ex.Message });
    }
    catch (Exception ex)
    {
        return Results.Problem(ex.Message);
    }
});

app.MapGet("/", () => "Infonetica Workflow Engine API is running");

app.Run();
