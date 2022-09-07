state("Fashion Police Squad") {}

startup
{
	vars.Log = (Action<object>)(output => print("[FPS] " + output));
	vars.Unity = Assembly.Load(File.ReadAllBytes(@"Components\UnityASL.bin")).CreateInstance("UnityASL.Unity");
	vars.Unity.LoadSceneManager = true;

	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var mbox = MessageBox.Show(
			"The Fashion Police Squad auto-splitter uses in-game time.\nWould you like to switch to it?",
			"LiveSplit | Fashion Police Squad",
			MessageBoxButtons.YesNo);

		if (mbox == DialogResult.Yes)
			timer.CurrentTimingMethod = TimingMethod.GameTime;
	}
}

init
{
	current.Event = "";
	current.Scene = -1;

	vars.Unity.TryOnLoad = (Func<dynamic, bool>)(helper =>
	{
		var loadManager = helper.GetClass("Assembly-CSharp", "LevelLoadingManager");

		vars.Unity.Make<bool>(loadManager.Static, loadManager["Loading"]).Name = "loading";

		return true;
	});

	vars.Unity.Load(game);
}

update
{
	if (!vars.Unity.Loaded)
		return false;

	vars.Unity.Update();

  current.isLoading = vars.Unity["loading"].Current;
  
	current.Scene = vars.Unity.Scenes.Active.Name;
}

start
{
	return old.Scene != "001-intro-cinematic" && current.Scene == "001-intro-cinematic";
}

split
{
	if (old.Scene != "Runway" && current.Scene == "Runway")
	{
		vars.Log("Scene changed: " + old.Scene + " -> " + current.Scene);

    return true;
	}

  return false;
}

reset
{
  return old.Scene != "MainMenu" && current.Scene == "MainMenu";
}

isLoading
{
	return current.isLoading;
}

exit
{
	vars.Unity.Reset();
}

shutdown
{
	vars.Unity.Reset();
}