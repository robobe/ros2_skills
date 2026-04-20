---
name: ros2-workspace-creator
description: Create a standard ROS 2 C++ workspace with src plus four packages prefix_description, prefix_gazebo, prefix_bringup, and prefix_application. setup vscode filers like settings.json and tasks.json. initialize git repository with .gitignore and README.md. copy initialize files like colcon_defaults.yaml and env.sh. create launch file to run gazebo and rviz
version: 0.1.0
---

# ROS 2 C++ workspace skill

Use this skill when the user wants to scaffold a new ROS 2 workspace in C++.

## Required environment setup
Before running any `ros2` or `colcon` command, start a Bash shell and source ROS Jazzy:

```bash
source /opt/ros/jazzy/setup.bash
```

## Ask for missing inputs
Before creating anything:
- ask for the workspace name if it is missing
- ask for the package prefix if it is missing

## Defaults
- build type: `ament_cmake`
- packages must be created under `<workspace_name>/src`
- use lowercase package names with underscores

- any placeholder text like `<prefix>` in copied files must be replaced with the actual package prefix before use

## Required packages
Create exactly these four packages:
- `<prefix>_description`
- `<prefix>_gazebo`
- `<prefix>_bringup`
- `<prefix>_application`

## Command pattern
From inside `<workspace_name>/src`, use:

- `ros2 pkg create <prefix>_description --build-type ament_cmake`
- `ros2 pkg create <prefix>_gazebo --build-type ament_cmake`
- `ros2 pkg create <prefix>_bringup --build-type ament_cmake`
- `ros2 pkg create <prefix>_application --build-type ament_cmake`


## Package version rule

Immediately after running `ros2 pkg create`, edit each package's `package.xml` and ensure it contains:

```xml
<version>0.0.1</version>
```

## Standard folders

### `<prefix>_description`
Create if missing:
- `urdf/`
- `meshes/`
- `models/`

### `<prefix>_gazebo`
Create if missing:
- `worlds/`
- `src/`

### `<prefix>_bringup`
Create if missing:
- `launch/`
- `config/`

Copy launch and config assets from the source assets folder into the bringup package:

```bash
cp -r assets/launch/* <workspace_name>/src/<prefix>_bringup/launch/
cp -r assets/config/* <workspace_name>/src/<prefix>_bringup/config/
cp assets/ros/gz.launch.yaml <workspace_name>/src/<prefix>_bringup/launch/gz.launch.yaml
```

If `assets/ros/gz.launch.yaml` contains `<prefix>` placeholders, replace every occurrence with the real package prefix after copying. For example:

```bash
sed -i "s/<prefix>/<actual_prefix>/g" <workspace_name>/src/<prefix>_bringup/launch/gz.launch.yaml
```

Ensure `<prefix>_bringup/CMakeLists.txt` installs the package assets so they are available after `colcon build`:

```cmake
install(DIRECTORY launch config
  DESTINATION share/${PROJECT_NAME}
)
```

Ensure `<prefix>_gazebo/CMakeLists.txt` installs the package assets so they are available after `colcon build`:

```cmake
install(DIRECTORY worlds
  DESTINATION share/${PROJECT_NAME}
)
```

Ensure `<prefix>_description/CMakeLists.txt` installs the package assets so they are available after `colcon build`:

```cmake
install(DIRECTORY urdf meshes models
  DESTINATION share/${PROJECT_NAME}
)
```

If the package is built successfully, the workspace-level `install/` directory will be created in `<workspace_name>/install`.

### `<prefix>_application`
Create if missing:
- `src/`
- `include/<prefix>_application/`

Inside `<prefix>_application/`, create:
- `__init__.py`
- `main.py`

### remove folder from `<prefix>_description` and `<prefix>_bringup` if it exists:
- `src/`
- `include/`

### remove folder from `<prefix>_application` if it exists:
- `launch/`
- `config/`

## Hybrid Python support for `<prefix>_application`
For the `<prefix>_application` package, also enable Python package installation.

Update `CMakeLists.txt` for `<prefix>_application` as follows:

1. Ensure this line exists:
   - `find_package(ament_cmake_python REQUIRED)`

2. Ensure this line exists before `ament_package()`:
   - `ament_python_install_package(${PROJECT_NAME})`

3. Install Python nodes with:
   - `set(NODES`
   - `  <prefix>_application/main.py`
   - `)`
   - `install(PROGRAMS ${NODES} DESTINATION lib/${PROJECT_NAME})`

4. Mark Python node files as executable when appropriate.

## VS Code configuration

After creating the workspace, set up VS Code integration:

1. In the workspace root directory (`<workspace_name>/`), create a `.vscode` folder:
   ```bash
   mkdir -p <workspace_name>/.vscode
   ```

2. Copy the configuration files from assets/vscode to the `.vscode` folder:
   ```bash
   cp assets/vscode/settings.json <workspace_name>/.vscode/settings.json
   cp assets/vscode/tasks.json <workspace_name>/.vscode/tasks.json
   ```

These files configure:
- **settings.json**: VS Code editor settings for the workspace
- **tasks.json**: VS Code build and ROS 2 tasks



## workspace setup

After creating the workspace and packages, set up root files and initialize version control:

1. Copy configuration files to workspace root:
   ```bash
   cp assets/colcon_defaults.yaml <workspace_name>/colcon_defaults.yaml
   ```

2. Copy env file from assets to workspace root:
   
   ```bash
   cp assets/env.sh <workspace_name>/env.sh
   chmod +x <workspace_name>/env.sh
   ```

   - If `env.sh` contains any `<prefix>` placeholders, replace every occurrence with the real package prefix before using it.

3. Create a README.md file:
   ```bash
   cat > <workspace_name>/README.md << 'EOF'
   # <workspace_name>

   A ROS 2 workspace containing the following packages:
   - <prefix>_description: Robot description and URDF files
   - <prefix>_gazebo: Gazebo simulation configuration
   - <prefix>_bringup: Launch files and configuration
   - <prefix>_application: Main application with C++/Python hybrid support

   ## Setup

   1. Source ROS 2:
      ```bash
      source /opt/ros/jazzy/setup.bash
      ```

   2. Build the workspace:
      ```bash
      cd <workspace_name>
      colcon build
      source install/setup.bash
      ```

   ## Usage

   [Add usage instructions here]

   ## Dependencies

   [List any additional dependencies here]
   EOF
   ```

4. Initialize git repository:
   ```bash
   cd <workspace_name>
   git init
   ```

5. Copy `.gitignore` from assets to the workspace root:
   ```bash
   cp assets/.gitignore <workspace_name>/.gitignore
   ```

6. Add initial commit:
   ```bash
   git add .
   git commit -m "Initial ROS 2 workspace setup"
   ```

## Final validation

As the last step of the workflow, run the scaffold validation test from the skill repository root:

```bash
./tests/test_generated_workspace.sh <workspace_name> <prefix>
```

The workflow is not complete unless this test passes. If it fails, fix the generated workspace and rerun the test before reporting the result.

## Constraints
- do not modify files outside the target workspace
- do not overwrite existing files without warning
- do not invent robot-specific code, URDF, controllers, or Gazebo plugins unless requested
- keep generated files minimal unless the user asks for more

## Output
At the end, report:
- workspace path
- prefix used
- packages created
- folders created
- any manual next steps
