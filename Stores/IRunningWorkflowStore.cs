using InfoneticaWorkflowEngine.Models;

namespace InfoneticaWorkflowEngine.Stores;

public interface IRunningWorkflowStore
{
    RunningWorkflow? GetById(string id);
    IEnumerable<RunningWorkflow> GetAll();
    void Add(RunningWorkflow workflow);
    void Update(RunningWorkflow workflow);
}
