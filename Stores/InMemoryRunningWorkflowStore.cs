using InfoneticaWorkflowEngine.Models;
using System.Collections.Concurrent;

namespace InfoneticaWorkflowEngine.Stores;

public class InMemoryRunningWorkflowStore : IRunningWorkflowStore
{
    private readonly ConcurrentDictionary<string, RunningWorkflow> _workflows = new();

    public RunningWorkflow? GetById(string id)
    {
        _workflows.TryGetValue(id, out var workflow);
        return workflow;
    }

    public IEnumerable<RunningWorkflow> GetAll()
    {
        return _workflows.Values;
    }

    public void Add(RunningWorkflow workflow)
    {
        _workflows.TryAdd(workflow.Id, workflow);
    }

    public void Update(RunningWorkflow workflow)
    {
        _workflows.AddOrUpdate(workflow.Id, workflow, (key, old) => workflow);
    }
}
