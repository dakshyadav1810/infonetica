namespace InfoneticaWorkflowEngine.Models;

public record WorkflowState(
    string Id,
    string Name,
    bool IsInitial = false,
    bool IsFinal = false,
    bool IsEnabled = true
);
