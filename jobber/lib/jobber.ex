defmodule Jobber do
  alias Jobber.{JobRunner, JobSupervisor, JobRegistry}

  @quota 5

  def start_job(args) do
    if Enum.count(running_imports()) >= @quota do
      {:error, :import_quota_reached}
    else
      DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
    end
  end

  def running_imports do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:==, :"$3", "import"}]
    map_result = [%{id: :"$1", pid: :"$2", type: :"$3"}]
    Registry.select(JobRegistry, [{match_all, guards, map_result}])
  end
end
