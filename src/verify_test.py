from pathlib import Path

from .verify import ExerciseSeeker


def test_is_exercise_done_true(mocker):
    file_content = """Lorem ipsum
Some text
More text"""
    m = mocker.patch("builtins.open", mocker.mock_open(read_data=file_content))

    res = ExerciseSeeker._is_exercise_done("foo")
    m.assert_called_once_with("foo", "r")
    assert res == True


def test_is_exercise_done_false(mocker):
    file_content = """Lorem ipsum
# I AM NOT DONE
Some text
More text"""

    m = mocker.patch("builtins.open", mocker.mock_open(read_data=file_content))

    res = ExerciseSeeker._is_exercise_done("foo")
    m.assert_called_once_with("foo", "r")
    assert res == False


def test_find_next_exercise_all_false(mocker):
    def mock_is_exercise_done():
        return False

    seeker = ExerciseSeeker(
        [("dir0", ["ex00", "ex01"]), ("dir1", ["ex00", "ex01"])], Path("root")
    )
    m = mocker.patch.object(
        ExerciseSeeker,
        "_is_exercise_done",
    )
    m.side_effect = lambda x: mock_is_exercise_done()

    assert seeker.find_next_exercise() == Path("root/dir0/ex00.cairo")


def test_find_next_exercise_all_true(mocker):
    def mock_is_exercise_done():
        return True

    seeker = ExerciseSeeker(
        [("dir0", ["ex00", "ex01"]), ("dir1", ["ex00", "ex01"])], Path("root")
    )
    m = mocker.patch.object(
        ExerciseSeeker,
        "_is_exercise_done",
    )
    m.side_effect = lambda x: mock_is_exercise_done()

    assert seeker.find_next_exercise() == None


def test_find_next_exercise(mocker):
    def mock_is_exercise_done():
        res = True

        if mock_is_exercise_done.counter >= 2:
            res = False

        mock_is_exercise_done.counter += 1
        return res

    mock_is_exercise_done.counter = 0

    seeker = ExerciseSeeker(
        [("dir0", ["ex00", "ex01"]), ("dir1", ["ex00", "ex01"])], Path("root")
    )
    m = mocker.patch.object(
        ExerciseSeeker,
        "_is_exercise_done",
    )
    m.side_effect = lambda x: mock_is_exercise_done()

    assert seeker.find_next_exercise() == Path("root/dir1/ex00.cairo")
