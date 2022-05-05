from pathlib import Path
import subprocess
from src.protostar import protostar_bin

script_root = Path(__file__).parent / ".." / ".."


class ExerciceFailed(Exception):
    def __init__(self, message, **kwargs):
        super().__init__(**kwargs)
        self._message = message

    @property
    def message(self):
        return self._message


class ProtostarExerciseRunner:
    def __init__(self):
        self._protostar_bin = protostar_bin()

    async def run(self, exercise_path):
        test_run = subprocess.run(
            [self._protostar_bin, "test", exercise_path],
            capture_output=True,
            cwd=script_root,
            check=True,
        )
        if len(test_run.stderr) > 0:
            raise ExerciceFailed(test_run.stderr.decode("utf-8"))
        if "------- FAILURES --------" in test_run.stdout.decode("utf-8"):
            raise ExerciceFailed(test_run.stdout.decode("utf-8"))
