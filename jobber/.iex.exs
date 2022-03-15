good_job = fn ->
  Process.sleep(5_000)
  {:ok, []}
end

bad_job = fn ->
  Process.sleep(5_000)
  {:error, []}
end

boom_job = fn ->
  Process.sleep(5_000)
  raise "Boom!"
end
