using InfoneticaWorkflowEngine.Models;
using InfoneticaWorkflowEngine.Payloads;

namespace InfoneticaWorkflowEngine.Services;

public interface IWorkflowOrchestrator
{
    WorkflowBlueprint CreateBlueprint(CreateBlueprintPayload payload);
    RunningWorkflow StartWorkflow(StartWorkflowPayload payload);
    RunningWorkflow ExecuteAction(string workflowId, ExecuteActionOnWorkflowPayload payload);
    RunningWorkflow? GetRunningWorkflow(string workflowId);
    WorkflowBlueprint? GetBlueprint(string blueprintId);
    IEnumerable<WorkflowBlueprint> GetAllBlueprints();
    IEnumerable<RunningWorkflow> GetAllRunningWorkflows();
}
