defmodule HelloLights do
  @moduledoc """
  Simple example to blink a list of LEDs forever.

  The list of LEDs is platform-dependent, and defined in the config
  directory (see config.exs).   See README.md for build instructions.
  """
  alias Nerves.Networking

  @interface :eth0

  @on_duration  100 # ms
  @off_duration 100 # ms

  alias Nerves.Leds
  require Logger

  def start(_type, _args) do
    # Networking
    unless :os.type == {:unix, :darwin} do     # don't start networking unless we're on nerves
      {:ok, _} = Networking.setup @interface
    end

    # Leds
    led_list = Application.get_env(:hello_lights, :led_list)
    Logger.debug "list of leds to blink is #{inspect led_list}"
    spawn fn -> test_dns_forever(led_list) end

    {:ok, self()}
  end

  @doc "Test DNS connectivity forever"
  def test_dns_forever(led_list) do
    Enum.each(led_list, &test_dns(&1))
    test_dns_forever(led_list)
  end

  @doc "Attempts to perform a DNS lookup to test connectivity."
  def test_dns(led_key, hostname \\ 'evermade.fi') do
    case :inet_res.gethostbyname(hostname) do
      {:ok, _} ->
        Leds.set [{led_key, true}]
        :timer.sleep @on_duration
        Leds.set [{led_key, false}]
        :timer.sleep @off_duration
      _        ->
        Leds.set [{led_key, false}]
    end
  end
end
