using InfoneticaWorkflowEngine.Models;

namespace InfoneticaWorkflowEngine.Payloads;

public record CreateBlueprintPayload(
    string Name,
    List<WorkflowState> States,
    List<WorkflowAction> Actions
);
