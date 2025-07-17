namespace InfoneticaWorkflowEngine.Models;

public record WorkflowAction(
    string Id,
    string Name,
    bool IsEnabled,
    List<string> FromStates,
    string ToState
);
