namespace InfoneticaWorkflowEngine.Models;

public record RunningWorkflow(
    string Id,
    string BlueprintId,
    WorkflowState CurrentState,
    List<ActionHistoryEntry> History
);
