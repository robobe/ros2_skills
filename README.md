# ROS2 workspace creator

using codex skill to create ros2 workspace
create 4 packages, names:

> [!NOTE]
> The packages base on ament_cmake but application package support python nodes

<prefix>_application
<prefix>_bringup
<prefix>_description
<prefix>_gazebo

Add vscode helper files
- settings
- tasks

Add bash helper
- Add env.sh the run for each terminal that open by vscode

Add ros files
- colocon defaults

Add ros examples
- add empty world
- launch file to run gz harmonic with bridge

## prompt
create ros2 workspace under ~/workspaces folder use workspace=xxx_ws and prefix=xxx