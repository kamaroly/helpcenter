# lib/helpcenter/extensions/ash_parental/info.ex
defmodule Helpcenter.Extensions.AshParental.Info do
  use Spark.InfoGenerator, extension: Helpcenter.Extensions.AshParental, sections: [:ash_parental]
end
