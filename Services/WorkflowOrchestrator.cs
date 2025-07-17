using InfoneticaWorkflowEngine.Models;
using InfoneticaWorkflowEngine.Payloads;
using InfoneticaWorkflowEngine.Stores;

namespace InfoneticaWorkflowEngine.Services;

public class WorkflowOrchestrator : IWorkflowOrchestrator
{
    private readonly IBlueprintStore _blueprintStore;
    private readonly IRunningWorkflowStore _runningWorkflowStore;

    public WorkflowOrchestrator(IBlueprintStore blueprintStore, IRunningWorkflowStore runningWorkflowStore)
    {
        _blueprintStore = blueprintStore;
        _runningWorkflowStore = runningWorkflowStore;
    }

    public WorkflowBlueprint CreateBlueprint(CreateBlueprintPayload payload)
    {
        ValidateBlueprintPayload(payload);
        
        var blueprintId = Guid.NewGuid().ToString();
        var blueprint = new WorkflowBlueprint(blueprintId, payload.Name, payload.States, payload.Actions);
        
        _blueprintStore.Add(blueprint);
        return blueprint;
    }

    public RunningWorkflow StartWorkflow(StartWorkflowPayload payload)
    {
        var blueprint = _blueprintStore.GetById(payload.BlueprintId);
        if (blueprint == null)
            throw new ArgumentException($"Blueprint with ID '{payload.BlueprintId}' not found");

        var initialState = blueprint.States.FirstOrDefault(s => s.IsInitial);
        if (initialState == null)
            throw new InvalidOperationException("Blueprint must have exactly one initial state");

        var workflowId = Guid.NewGuid().ToString();
        var workflow = new RunningWorkflow(
            workflowId,
            payload.BlueprintId,
            initialState,
            new List<ActionHistoryEntry>()
        );

        _runningWorkflowStore.Add(workflow);
        return workflow;
    }

    public RunningWorkflow ExecuteAction(string workflowId, ExecuteActionOnWorkflowPayload payload)
    {
        var workflow = _runningWorkflowStore.GetById(workflowId);
        if (workflow == null)
            throw new ArgumentException($"Workflow with ID '{workflowId}' not found");

        var blueprint = _blueprintStore.GetById(workflow.BlueprintId);
        if (blueprint == null)
            throw new InvalidOperationException($"Blueprint with ID '{workflow.BlueprintId}' not found");

        if (workflow.CurrentState.IsFinal)
            throw new InvalidOperationException("Cannot execute actions on workflows in final state");

        var action = blueprint.Actions.FirstOrDefault(a => a.Id == payload.ActionId);
        if (action == null)
            throw new ArgumentException($"Action with ID '{payload.ActionId}' not found in blueprint");

        if (!action.IsEnabled)
            throw new InvalidOperationException($"Action '{action.Name}' is disabled");

        if (!action.FromStates.Contains(workflow.CurrentState.Id))
            throw new InvalidOperationException($"Action '{action.Name}' cannot be executed from current state '{workflow.CurrentState.Name}'");

        var toState = blueprint.States.FirstOrDefault(s => s.Id == action.ToState);
        if (toState == null)
            throw new InvalidOperationException($"Target state '{action.ToState}' not found in blueprint");

        var historyEntry = new ActionHistoryEntry(payload.ActionId, DateTime.UtcNow);
        var updatedHistory = new List<ActionHistoryEntry>(workflow.History) { historyEntry };
        
        var updatedWorkflow = workflow with 
        { 
            CurrentState = toState, 
            History = updatedHistory 
        };

        _runningWorkflowStore.Update(updatedWorkflow);
        return updatedWorkflow;
    }

    public RunningWorkflow? GetRunningWorkflow(string workflowId)
    {
        return _runningWorkflowStore.GetById(workflowId);
    }

    public WorkflowBlueprint? GetBlueprint(string blueprintId)
    {
        return _blueprintStore.GetById(blueprintId);
    }

    public IEnumerable<WorkflowBlueprint> GetAllBlueprints()
    {
        return _blueprintStore.GetAll();
    }

    public IEnumerable<RunningWorkflow> GetAllRunningWorkflows()
    {
        return _runningWorkflowStore.GetAll();
    }

    private static void ValidateBlueprintPayload(CreateBlueprintPayload payload)
    {
        if (string.IsNullOrWhiteSpace(payload.Name))
            throw new ArgumentException("Blueprint name cannot be empty");

        if (payload.States == null || payload.States.Count == 0)
            throw new ArgumentException("Blueprint must have at least one state");

        if (payload.Actions == null)
            throw new ArgumentException("Blueprint actions cannot be null");

        var stateIds = payload.States.Select(s => s.Id).ToList();
        if (stateIds.Count != stateIds.Distinct().Count())
            throw new ArgumentException("All state IDs must be unique");

        var initialStates = payload.States.Where(s => s.IsInitial).ToList();
        if (initialStates.Count != 1)
            throw new ArgumentException("Blueprint must have exactly one initial state");

        foreach (var action in payload.Actions)
        {
            if (action.FromStates.Any(fromState => !stateIds.Contains(fromState)))
                throw new ArgumentException($"Action '{action.Name}' references invalid from state(s)");

            if (!stateIds.Contains(action.ToState))
                throw new ArgumentException($"Action '{action.Name}' references invalid to state '{action.ToState}'");
        }
    }
}
