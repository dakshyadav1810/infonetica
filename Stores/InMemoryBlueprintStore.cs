using InfoneticaWorkflowEngine.Models;
using System.Collections.Concurrent;

namespace InfoneticaWorkflowEngine.Stores;

public class InMemoryBlueprintStore : IBlueprintStore
{
    private readonly ConcurrentDictionary<string, WorkflowBlueprint> _blueprints = new();

    public WorkflowBlueprint? GetById(string id)
    {
        _blueprints.TryGetValue(id, out var blueprint);
        return blueprint;
    }

    public IEnumerable<WorkflowBlueprint> GetAll()
    {
        return _blueprints.Values;
    }

    public void Add(WorkflowBlueprint blueprint)
    {
        _blueprints.TryAdd(blueprint.Id, blueprint);
    }
}
