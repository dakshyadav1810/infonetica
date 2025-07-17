namespace InfoneticaWorkflowEngine.Models;

public record WorkflowBlueprint(
    string Id,
    string Name,
    List<WorkflowState> States,
    List<WorkflowAction> Actions
);
