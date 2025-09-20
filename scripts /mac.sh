#!/bin/bash
set -o pipefail

# ===== Global Variables =====
WORKSPACE_DIR="$HOME/.browserstack"
PROJECT_FOLDER="NOW"

BROWSERSTACK_USERNAME=""
BROWSERSTACK_ACCESS_KEY=""
TEST_TYPE=""       # Web / App / Both
TECH_STACK=""      # Java / Python / JS

PARALLEL_PERCENTAGE=1.00

WEB_PLAN_FETCHED=false
MOBILE_PLAN_FETCHED=false
TEAM_PARALLELS_MAX_ALLOWED_WEB=0
TEAM_PARALLELS_MAX_ALLOWED_MOBILE=0

# URL handling
DEFAULT_TEST_URL="https://bstackdemo.com/"
CX_TEST_URL="$DEFAULT_TEST_URL"

# ===== Error Patterns =====
WEB_SETUP_ERRORS=("")
WEB_LOCAL_ERRORS=("")

MOBILE_SETUP_ERRORS=("")
MOBILE_LOCAL_ERRORS=("")

# ===== Example Platform Templates (replace with your full lists if available) =====
WEB_PLATFORM_TEMPLATES=(
  "Windows|10|Chrome"
  "Windows|10|Firefox"
  "Windows|11|Edge"
  "Windows|11|Chrome"
  "Windows|8|Chrome"
  "OS X|Monterey|Safari"
  "OS X|Monterey|Chrome"
  "OS X|Ventura|Chrome"
  "OS X|Big Sur|Safari"
  "OS X|Catalina|Firefox"
)


MOBILE_TIER1=(
  "ios|iPhone latest|latest"
  # "ios|iPhone 15 Pro|17"
  # "ios|iPhone 16|18"
  "android|Samsung Galaxy *|*"
  # "android|Samsung Galaxy S24|14"
)

# Tier 2 – Up to 40 parallels
MOBILE_TIER2=(
  "ios|iPhone 14 Pro|16"
  "ios|iPhone 14|16"
  "ios|iPad Air 13 2025|18"
  "android|Samsung Galaxy S23|13"
  "android|Samsung Galaxy S22|12"
  "android|Samsung Galaxy S21|11"
  "android|Samsung Galaxy Tab S10 Plus|15"
)

# Tier 3 – Up to 16 parallels
MOBILE_TIER3=(
  "ios|iPhone 13 Pro Max|15"
  "ios|iPhone 13|15"
  "ios|iPhone 12 Pro|14"
  "ios|iPhone 12 Pro|17"
  "ios|iPhone 12|17"
  "ios|iPhone 12|14"
  "ios|iPhone 12 Pro Max|16"
  "ios|iPhone 13 Pro|15"
  "ios|iPhone 13 Mini|15"
  "ios|iPhone 16 Pro|18"
  "ios|iPad 9th|15"
  "ios|iPad Pro 12.9 2020|14"
  "ios|iPad Pro 12.9 2020|16"
  "ios|iPad 8th|16"
  "android|Samsung Galaxy S22 Ultra|12"
  "android|Samsung Galaxy S21|12"
  "android|Samsung Galaxy S21 Ultra|11"
  "android|Samsung Galaxy S20|10"
  "android|Samsung Galaxy M32|11"
  "android|Samsung Galaxy Note 20|10"
  "android|Samsung Galaxy S10|9"
  "android|Samsung Galaxy Note 9|8"
  "android|Samsung Galaxy Tab S8|12"
  "android|Google Pixel 9|15"
  "android|Google Pixel 6 Pro|13"
  "android|Google Pixel 8|14"
  "android|Google Pixel 7|13"
  "android|Google Pixel 6|12"
  "android|Vivo Y21|11"
  "android|Vivo Y50|10"
  "android|Oppo Reno 6|11"
)

# Tier 4 – Up to 5 parallels
MOBILE_TIER4=(
  "ios|iPhone 15 Pro Max|17"
  "ios|iPhone 15 Pro Max|26"
  "ios|iPhone 15|26"
  "ios|iPhone 15 Plus|17"
  "ios|iPhone 14 Pro|26"
  "ios|iPhone 14|18"
  "ios|iPhone 14|26"
  "ios|iPhone 13 Pro Max|18"
  "ios|iPhone 13|16"
  "ios|iPhone 13|17"
  "ios|iPhone 13|18"
  "ios|iPhone 12 Pro|18"
  "ios|iPhone 14 Pro Max|16"
  "ios|iPhone 14 Plus|16"
  "ios|iPhone 11|13"
  "ios|iPhone 8|11"
  "ios|iPhone 7|10"
  "ios|iPhone 17 Pro Max|26"
  "ios|iPhone 17 Pro|26"
  "ios|iPhone 17 Air|26"
  "ios|iPhone 17|26"
  "ios|iPhone 16e|18"
  "ios|iPhone 16 Pro Max|18"
  "ios|iPhone 16 Plus|18"
  "ios|iPhone SE 2020|16"
  "ios|iPhone SE 2022|15"
  "ios|iPad Air 4|14"
  "ios|iPad 9th|18"
  "ios|iPad Air 5|26"
  "ios|iPad Pro 11 2021|18"
  "ios|iPad Pro 13 2024|17"
  "ios|iPad Pro 12.9 2021|14"
  "ios|iPad Pro 12.9 2021|17"
  "ios|iPad Pro 11 2024|17"
  "ios|iPad Air 6|17"
  "ios|iPad Pro 12.9 2022|16"
  "ios|iPad Pro 11 2022|16"
  "ios|iPad 10th|16"
  "ios|iPad Air 13 2025|26"
  "ios|iPad Pro 11 2020|13"
  "ios|iPad Pro 11 2020|16"
  "ios|iPad 8th|14"
  "ios|iPad Mini 2021|15"
  "ios|iPad Pro 12.9 2018|12"
  "ios|iPad 6th|11"
  "android|Samsung Galaxy S23 Ultra|13"
  "android|Samsung Galaxy S22 Plus|12"
  "android|Samsung Galaxy S21 Plus|11"
  "android|Samsung Galaxy S20 Ultra|10"
  "android|Samsung Galaxy S25 Ultra|15"
  "android|Samsung Galaxy S24 Ultra|14"
  "android|Samsung Galaxy M52|11"
  "android|Samsung Galaxy A52|11"
  "android|Samsung Galaxy A51|10"
  "android|Samsung Galaxy A11|10"
  "android|Samsung Galaxy A10|9"
  "android|Samsung Galaxy Tab A9 Plus|14"
  "android|Samsung Galaxy Tab S9|13"
  "android|Samsung Galaxy Tab S7|10"
  "android|Samsung Galaxy Tab S7|11"
  "android|Samsung Galaxy Tab S6|9"
  "android|Google Pixel 9|16"
  "android|Google Pixel 10 Pro XL|16"
  "android|Google Pixel 10 Pro|16"
  "android|Google Pixel 10|16"
  "android|Google Pixel 9 Pro XL|15"
  "android|Google Pixel 9 Pro|15"
  "android|Google Pixel 6 Pro|12"
  "android|Google Pixel 6 Pro|15"
  "android|Google Pixel 8 Pro|14"
  "android|Google Pixel 7 Pro|13"
  "android|Google Pixel 5|11"
  "android|OnePlus 13R|15"
  "android|OnePlus 12R|14"
  "android|OnePlus 11R|13"
  "android|OnePlus 9|11"
  "android|OnePlus 8|10"
  "android|Motorola Moto G71 5G|11"
  "android|Motorola Moto G9 Play|10"
  "android|Vivo V21|11"
  "android|Oppo A96|11"
  "android|Oppo Reno 3 Pro|10"
  "android|Xiaomi Redmi Note 11|11"
  "android|Xiaomi Redmi Note 9|10"
  "android|Huawei P30|9"
)



APP_URL=""
APP_PLATFORM=""   # ios | android | all



# ===== Log files (runtime only; created on first write) =====
# ===== Log files (per-run) =====
LOG_DIR="$WORKSPACE_DIR/$PROJECT_FOLDER/logs"
GLOBAL="$LOG_DIR/global.log"
WEB_LOG_FILE="$LOG_DIR/web_run_result.log"
MOBILE_LOG_FILE="$LOG_DIR/mobile_run_result.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Clear old logs to start fresh
: > "$GLOBAL"
: > "$WEB_LOG_FILE"
: > "$MOBILE_LOG_FILE"

# ===== Logging helper (runtime timestamped logging) =====
# Usage: log_msg_to "message" "$DEST_FILE"  (DEST_FILE optional; prints to console always)
log_msg_to() {
  local message="$1"
  local dest_file="$2"    # optional
  local ts
  ts="$(date +"%Y-%m-%d %H:%M:%S")"
  local line="[$ts] $message"

  # print to console
  echo "$line"

  # write to dest file if provided
  if [ -n "$dest_file" ]; then
    mkdir -p "$(dirname "$dest_file")"
    echo "$line" >> "$dest_file"
  fi
}

# ===== validate_prereqs shim (keeps compatibility with older code) =====
validate_prereqs() {
  # For backwards compatibility call validate_tech_stack_installed
  validate_tech_stack_installed
}

# ===== Functions: baseline interactions =====
setup_workspace() {
    local full_path="$WORKSPACE_DIR/$PROJECT_FOLDER"
    if [ ! -d "$full_path" ]; then
        mkdir -p "$full_path"
        log_msg_to "✅ Created Onboarding workspace: $full_path" "$GLOBAL"
    else
        log_msg_to "ℹ️ Onboarding Workspace already exists: $full_path" "$GLOBAL"
    fi
}

ask_browserstack_credentials() {
    # Prompt username
    BROWSERSTACK_USERNAME=$(osascript -e 'Tell application "System Events" to display dialog "Enter your BrowserStack Username:" default answer "" with title "BrowserStack Setup" buttons {"OK"} default button "OK"' \
                            -e 'text returned of result')
    if [ -z "$BROWSERSTACK_USERNAME" ]; then
        log_msg_to "❌ Username empty" "$GLOBAL"
        exit 1
    fi

    # Prompt access key (hidden)
    BROWSERSTACK_ACCESS_KEY=$(osascript -e 'Tell application "System Events" to display dialog "Enter your BrowserStack Access Key:" default answer "" with hidden answer with title "BrowserStack Setup" buttons {"OK"} default button "OK"' \
                             -e 'text returned of result')
    if [ -z "$BROWSERSTACK_ACCESS_KEY" ]; then
        log_msg_to "❌ Access Key empty" "$GLOBAL"
        exit 1
    fi

    log_msg_to "✅ BrowserStack credentials captured (access key hidden)" "$GLOBAL"
}

# ask_test_type() {
#     TEST_TYPE=$(osascript -e 'Tell application "System Events" to display dialog "Select testing type:" buttons {"Web", "App", "Both"} default button "Web" with title "Testing Type"' \
#                           -e 'button returned of result')
#     log_msg_to "✅ Selected Testing Type: $TEST_TYPE" "$GLOBAL"
# }

# ask_tech_stack() {
#     TECH_STACK=$(osascript -e 'Tell application "System Events" to display dialog "Select installed tech stack:" buttons {"Java", "Python", "JS"} default button "Java" with title "Tech Stack"' \
#                         -e 'button returned of result')
#     log_msg_to "✅ Selected Tech Stack: $TECH_STACK" "$GLOBAL"
# }

ask_tech_stack() {
    TECH_STACK=$(osascript -e 'Tell application "System Events" to display dialog "Select installed tech stack:" buttons {"Java", "Python"} default button "Java" with title "Tech Stack"' \
                        -e 'button returned of result')
    log_msg_to "✅ Selected Tech Stack: $TECH_STACK" "$GLOBAL"
}



validate_tech_stack_installed() {
    log_msg_to "ℹ️ Checking prerequisites for $TECH_STACK" "$GLOBAL"

    case "$TECH_STACK" in
        Java)
            log_msg_to "🔍 Checking if 'java' command exists..." "$GLOBAL"
            if ! command -v java >/dev/null 2>&1; then
                log_msg_to "❌ Java command not found in PATH." "$GLOBAL"
                exit 1
            fi

            log_msg_to "🔍 Checking if Java runs correctly..." "$GLOBAL"
            if ! JAVA_VERSION_OUTPUT=$(java -version 2>&1); then
                log_msg_to "❌ Java exists but failed to run." "$GLOBAL"
                exit 1
            fi

            log_msg_to "✅ Java is installed. Version details:" "$GLOBAL"
            echo "$JAVA_VERSION_OUTPUT" | while read -r l; do log_msg_to "  $l" "$GLOBAL"; done
            ;;
        Python)
            log_msg_to "🔍 Checking if 'python3' command exists..." "$GLOBAL"
            if ! command -v python3 >/dev/null 2>&1; then
                log_msg_to "❌ Python3 command not found in PATH." "$GLOBAL"
                exit 1
            fi

            log_msg_to "🔍 Checking if Python3 runs correctly..." "$GLOBAL"
            if ! PYTHON_VERSION_OUTPUT=$(python3 --version 2>&1); then
                log_msg_to "❌ Python3 exists but failed to run." "$GLOBAL"
                exit 1
            fi

            log_msg_to "✅ Python3 is installed: $PYTHON_VERSION_OUTPUT" "$GLOBAL"
            ;;
        JS|JavaScript)
            log_msg_to "🔍 Checking if 'node' command exists..." "$GLOBAL"
            if ! command -v node >/dev/null 2>&1; then
                log_msg_to "❌ Node.js command not found in PATH." "$GLOBAL"
                exit 1
            fi
            log_msg_to "🔍 Checking if 'npm' command exists..." "$GLOBAL"
            if ! command -v npm >/dev/null 2>&1; then
                log_msg_to "❌ npm command not found in PATH." "$GLOBAL"
                exit 1
            fi

            log_msg_to "🔍 Checking if Node.js runs correctly..." "$GLOBAL"
            if ! NODE_VERSION_OUTPUT=$(node -v 2>&1); then
                log_msg_to "❌ Node.js exists but failed to run." "$GLOBAL"
                exit 1
            fi

            log_msg_to "🔍 Checking if npm runs correctly..." "$GLOBAL"
            if ! NPM_VERSION_OUTPUT=$(npm -v 2>&1); then
                log_msg_to "❌ npm exists but failed to run." "$GLOBAL"
                exit 1
            fi

            log_msg_to "✅ Node.js is installed: $NODE_VERSION_OUTPUT" "$GLOBAL"
            log_msg_to "✅ npm is installed: $NPM_VERSION_OUTPUT" "$GLOBAL"
            ;;
        *)
            log_msg_to "❌ Unknown tech stack selected: $TECH_STACK" "$GLOBAL"
            exit 1
            ;;
    esac

    log_msg_to "✅ Prerequisites validated for $TECH_STACK" "$GLOBAL"
}

# ===== Ask user for test URL via UI prompt =====
ask_user_for_test_url() {
  CX_TEST_URL=$(osascript -e 'Tell application "System Events" to display dialog "Enter the URL you want to test with BrowserStack:\n(Leave blank for default: '"$DEFAULT_TEST_URL"')" default answer "" with title "Test URL Setup" buttons {"OK"} default button "OK"' \
                  -e 'text returned of result')

  if [ -n "$CX_TEST_URL" ]; then
    log_msg_to "🌐 Using custom test URL: $CX_TEST_URL" "$PRE_RUN_LOG_FILE"
  else
    CX_TEST_URL="$DEFAULT_TEST_URL"
    log_msg_to "⚠️ No URL entered. Falling back to default: $CX_TEST_URL" "$PRE_RUN_LOG_FILE"
  fi
}

ask_and_upload_app() {
  APP_FILE_PATH=$(osascript -e 'POSIX path of (choose file with prompt "📱 Please select your .apk or .ipa app file to upload to BrowserStack, If No App Selected then Defualt Browserstack app will be used automatically")')

  if [ -z "$APP_FILE_PATH" ]; then
    log_msg_to "⚠️ No app selected. Using default sample app: bs://sample.app" "$GLOBAL"
    APP_URL="bs://sample.app"
    APP_PLATFORM="all"
    return
  fi

  # Detect platform
  if [[ "$APP_FILE_PATH" == *.apk ]]; then
    APP_PLATFORM="android"
  elif [[ "$APP_FILE_PATH" == *.ipa ]]; then
    APP_PLATFORM="ios"
  else
    log_msg_to "❌ Unsupported file type. Only .apk or .ipa allowed." "$GLOBAL"
    exit 1
  fi

  # Upload app
  log_msg_to "⬆️ Uploading $APP_FILE_PATH to BrowserStack..." "$GLOBAL"
  UPLOAD_RESPONSE=$(curl -s -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
    -X POST "https://api-cloud.browserstack.com/app-automate/upload" \
    -F "file=@$APP_FILE_PATH")

  APP_URL=$(echo "$UPLOAD_RESPONSE" | grep -o '"app_url":"[^"]*' | cut -d'"' -f4)

  if [ -z "$APP_URL" ]; then
    log_msg_to "❌ Upload failed. Response: $UPLOAD_RESPONSE" "$GLOBAL"
    exit 1
  fi

  log_msg_to "✅ App uploaded successfully: $APP_URL" "$GLOBAL"
}

ask_test_type() {
    TEST_TYPE=$(osascript -e 'Tell application "System Events" to display dialog "Select testing type:" buttons {"Web", "App", "Both"} default button "Web" with title "Testing Type"' \
                          -e 'button returned of result')
    log_msg_to "✅ Selected Testing Type: $TEST_TYPE" "$GLOBAL"

    case "$TEST_TYPE" in
      "Web")
        ask_user_for_test_url
        ;;
      "App")
        ask_and_upload_app
        ;;
      "Both")
        ask_user_for_test_url
        ask_and_upload_app
        ;;
    esac
}


# ===== Dynamic config generators =====
generate_web_platforms_yaml() {
  local max_total_parallels=$1
  local max
  max=$(echo "$max_total_parallels * $PARALLEL_PERCENTAGE" | bc | cut -d'.' -f1)
  [ -z "$max" ] && max=0
  local yaml=""
  local count=0

  for template in "${WEB_PLATFORM_TEMPLATES[@]}"; do
    IFS="|" read -r os osVersion browserName <<< "$template"
    for version in latest latest-1 latest-2; do
      yaml+="  - os: $os
    osVersion: $osVersion
    browserName: $browserName
    browserVersion: $version
"
      count=$((count + 1))
      if [ "$count" -ge "$max" ]; then
        echo "$yaml"
        return
      fi
    done
  done

  echo "$yaml"
}

# generate_mobile_platforms_yaml() {
#   local max_total_parallels=$1
#   local max
#   max=$(echo "$max_total_parallels * $PARALLEL_PERCENTAGE" | bc | cut -d'.' -f1)
#   [ -z "$max" ] && max=0
#   local yaml=""
#   local count=0

#   for template in "${MOBILE_DEVICE_TEMPLATES[@]}"; do
#     IFS="|" read -r platformName deviceName platformVersion <<< "$template"
#     yaml+="  - platformName: $platformName
#     deviceName: $deviceName
#     platformVersion: '${platformVersion}.0'
# "
#     count=$((count + 1))
#     if [ "$count" -ge "$max" ]; then
#       echo "$yaml"
#       return
#     fi
#   done

#   echo "$yaml"
# }


# Global vars
APP_URL=""
APP_PLATFORM=""   # ios | android | all

ask_and_upload_app() {
  APP_FILE_PATH=$(osascript -e 'POSIX path of (choose file with prompt "📱 Please select your .apk or .ipa app file to upload to BrowserStack")')

  if [ -z "$APP_FILE_PATH" ]; then
    log_msg_to "⚠️ No app selected. Using default sample app: bs://sample.app" "$GLOBAL"
    APP_URL="bs://sample.app"
    APP_PLATFORM="all"
    return
  fi

  # Detect platform
  if [[ "$APP_FILE_PATH" == *.apk ]]; then
    APP_PLATFORM="android"
  elif [[ "$APP_FILE_PATH" == *.ipa ]]; then
    APP_PLATFORM="ios"
  else
    log_msg_to "❌ Unsupported file type. Only .apk or .ipa allowed." "$GLOBAL"
    exit 1
  fi

  # Upload app
  log_msg_to "⬆️ Uploading $APP_FILE_PATH to BrowserStack..." "$GLOBAL"
  UPLOAD_RESPONSE=$(curl -s -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
    -X POST "https://api-cloud.browserstack.com/app-automate/upload" \
    -F "file=@$APP_FILE_PATH")

  APP_URL=$(echo "$UPLOAD_RESPONSE" | grep -o '"app_url":"[^"]*' | cut -d'"' -f4)

  if [ -z "$APP_URL" ]; then
    log_msg_to "❌ Upload failed. Response: $UPLOAD_RESPONSE" "$GLOBAL"
    exit 1
  fi

  log_msg_to "✅ App uploaded successfully: $APP_URL" "$GLOBAL"
}

generate_mobile_platforms_yaml() {
  local max_total_parallels=$1
  local yaml=""
  local count=0

  # Select tier based on parallel count
  if (( max_total_parallels >= 80 )); then
    devices=("${MOBILE_TIER1[@]}")
  elif (( max_total_parallels >= 40 )); then
    devices=("${MOBILE_TIER2[@]}")
  elif (( max_total_parallels >= 16 )); then
    devices=("${MOBILE_TIER3[@]}")
  else
    devices=("${MOBILE_TIER4[@]}")
  fi

  # Filter devices by platform and limit by max_total_parallels
  for template in "${devices[@]}"; do
    IFS="|" read -r platformName deviceName platformVersion <<< "$template"

    # Skip if platform mismatch
    if [[ "$APP_PLATFORM" == "ios" && "$platformName" != "ios" ]]; then
      continue
    fi
    if [[ "$APP_PLATFORM" == "android" && "$platformName" != "android" ]]; then
      continue
    fi

    yaml+="  - platformName: $platformName
    deviceName: $deviceName
    platformVersion: ${platformVersion}.0
"

    count=$((count + 1))
    if (( count >= max_total_parallels )); then
      break
    fi
  done

  echo "$yaml"
}



generate_web_caps_json() {
  local max_total_parallels=$1
  local max
  max=$(echo "$max_total_parallels * $PARALLEL_PERCENTAGE" | bc | cut -d'.' -f1)
  [ "$max" -lt 1 ] && max=1  # fallback to minimum 1

  local json=""
  local count=0

  for template in "${WEB_PLATFORM_TEMPLATES[@]}"; do
    IFS="|" read -r os osVersion browserName <<< "$template"
    for version in latest latest-1 latest-2; do
      json+="{
        \"browserName\": \"$browserName\",
        \"browserVersion\": \"$version\",
        \"bstack:options\": {
          \"os\": \"$os\",
          \"osVersion\": \"$osVersion\"
        }
      },"
      count=$((count + 1))
      if [ "$count" -ge "$max" ]; then
        json="${json%,}"  # strip trailing comma
        echo "$json"
        return
      fi
    done
  done

  # Fallback in case not enough combinations
  json="${json%,}"
  echo "$json"
}

generate_mobile_caps_json() {
  local max_total=$1
  local count=0
  local usage_file="/tmp/device_usage.txt"
  : > "$usage_file"

  local json="["
  for template in "${MOBILE_DEVICE_TEMPLATES[@]}"; do
    IFS="|" read -r platformName deviceName baseVersion <<< "$template"
    local usage
    usage=$(grep -Fxc "$deviceName" "$usage_file")

    if [ "$usage" -ge 5 ]; then
      continue
    fi

    json="${json}{
      \"bstack:options\": {
        \"deviceName\": \"${deviceName}\",
        \"osVersion\": \"${baseVersion}.0\"
      }
    },"

    echo "$deviceName" >> "$usage_file"
    count=$((count + 1))
    if [ "$count" -ge "$max_total" ]; then
      break
    fi
  done

  json="${json%,}]"
  echo "$json"
  rm -f "$usage_file"
}

# ===== Fetch plan details (writes to GLOBAL) =====
fetch_plan_details() {
    log_msg_to "ℹ️ Fetching BrowserStack Plan Details..." "$GLOBAL"
    local web_unauthorized=false
    local mobile_unauthorized=false

    if [[ "$TEST_TYPE" == "Web" || "$TEST_TYPE" == "Both" ]]; then
        RESPONSE_WEB=$(curl -s -w "\n%{http_code}" -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" https://api.browserstack.com/automate/plan.json)
        HTTP_CODE_WEB=$(echo "$RESPONSE_WEB" | tail -n1)
        RESPONSE_WEB_BODY=$(echo "$RESPONSE_WEB" | sed '$d')
        if [ "$HTTP_CODE_WEB" == "200" ]; then
            WEB_PLAN_FETCHED=true
            TEAM_PARALLELS_MAX_ALLOWED_WEB=$(echo "$RESPONSE_WEB_BODY" | grep -o '"parallel_sessions_max_allowed":[0-9]*' | grep -o '[0-9]*')
            log_msg_to "✅ Web Testing Plan fetched: Team max parallel sessions = $TEAM_PARALLELS_MAX_ALLOWED_WEB" "$GLOBAL"
        else
            log_msg_to "❌ Web Testing Plan fetch failed ($HTTP_CODE_WEB)" "$GLOBAL"
            [ "$HTTP_CODE_WEB" == "401" ] && web_unauthorized=true
        fi
    fi

    if [[ "$TEST_TYPE" == "App" || "$TEST_TYPE" == "Both" ]]; then
        RESPONSE_MOBILE=$(curl -s -w "\n%{http_code}" -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" https://api-cloud.browserstack.com/app-automate/plan.json)
        HTTP_CODE_MOBILE=$(echo "$RESPONSE_MOBILE" | tail -n1)
        RESPONSE_MOBILE_BODY=$(echo "$RESPONSE_MOBILE" | sed '$d')
        if [ "$HTTP_CODE_MOBILE" == "200" ]; then
            MOBILE_PLAN_FETCHED=true
            TEAM_PARALLELS_MAX_ALLOWED_MOBILE=$(echo "$RESPONSE_MOBILE_BODY" | grep -o '"parallel_sessions_max_allowed":[0-9]*' | grep -o '[0-9]*')
            log_msg_to "✅ Mobile App Testing Plan fetched: Team max parallel sessions = $TEAM_PARALLELS_MAX_ALLOWED_MOBILE" "$GLOBAL"
        else
            log_msg_to "❌ Mobile App Testing Plan fetch failed ($HTTP_CODE_MOBILE)" "$GLOBAL"
            [ "$HTTP_CODE_MOBILE" == "401" ] && mobile_unauthorized=true
        fi
    fi

    if [[ "$TEST_TYPE" == "Web" && "$web_unauthorized" == true ]] || \
       [[ "$TEST_TYPE" == "App" && "$mobile_unauthorized" == true ]] || \
       [[ "$TEST_TYPE" == "Both" && "$web_unauthorized" == true && "$mobile_unauthorized" == true ]]; then
        log_msg_to "❌ Unauthorized to fetch required plan(s). Exiting." "$GLOBAL"
        exit 1
    fi
}

# ===== Web setup per-tech functions (cloned/adapted) =====

# setup_web_javaOG() {
#   local local_flag=$1
#   local parallels=$2
#   local log_file=$3

#   REPO="testng-browserstack"
#   if [ ! -d "$REPO" ]; then
#     git clone https://github.com/browserstack/$REPO
#   fi
#   cd "$REPO" || return 1

#   validate_prereqs || return 1

#   platform_yaml=$(generate_web_platforms_yaml "$TEAM_PARALLELS_MAX_ALLOWED_WEB")
#   cat > browserstack.yml <<EOF
# userName: $BROWSERSTACK_USERNAME
# accessKey: $BROWSERSTACK_ACCESS_KEY
# framework: testng
# browserstackLocal: $local_flag
# buildName: browserstack-build-web
# projectName: BrowserStack Web Sample
# percy: true
# accessibility: true
# platforms:
# $platform_yaml
# EOF

#   mvn test -P sample-test > "$log_file" 2>&1 || true
#   # also copy logs to the pre-run log for visibility
#   [ -f "$log_file" ] && sed -n '1,200p' "$log_file" | while read -r l; do log_msg_to "web: $l" "$GLOBAL"; done
#   return 0
# }

setup_web_java() {
  local local_flag=$1
  local parallels=$2
  local log_file=$3

  REPO="browserstack-examples-testng"
  TARGET_DIR="$WORKSPACE_DIR/$PROJECT_FOLDER/$REPO"

  mkdir -p "$WORKSPACE_DIR/$PROJECT_FOLDER"

  if [ ! -d "$TARGET_DIR" ]; then
    log_msg_to "📦 Cloning repo $REPO into $TARGET_DIR" "$GLOBAL"
    git clone https://github.com/BrowserStackCE/$REPO.git "$TARGET_DIR"
  else
    log_msg_to "📂 Repo $REPO already exists at $TARGET_DIR, skipping clone." "$GLOBAL"
  fi

  cd "$TARGET_DIR" || return 1


  validate_prereqs || return 1

  # export credentials for Maven to use
  export BROWSERSTACK_USERNAME="$BROWSERSTACK_USERNAME"
  export BROWSERSTACK_ACCESS_KEY="$BROWSERSTACK_ACCESS_KEY"

  export BROWSERSTACK_CONFIG_FILE="src/test/resources/conf/capabilities/bstack-parallel.yml"
  # echo "$(pwd)"
  # echo "here i start"
  sed -i.bak "s|<CX_TEST_URL>|$CX_TEST_URL|g" src/test/java/com/browserstack/test/suites/TestBase.java
  # echo "here i starting"


  # log local flag status
  if [ "$local_flag" = "true" ]; then
    log_msg_to "⚠️ BrowserStack Local is ENABLED for this run." "$GLOBAL"
  else
    log_msg_to "⚠️ BrowserStack Local is DISABLED for this run." "$GLOBAL"
  fi

  # build platforms yaml content
  platform_yaml=$(generate_web_platforms_yaml "$TEAM_PARALLELS_MAX_ALLOWED_WEB")

  # overwrite target YAML file with new config
  cat > src/test/resources/conf/capabilities/bstack-parallel.yml <<EOF
userName: $BROWSERSTACK_USERNAME
accessKey: $BROWSERSTACK_ACCESS_KEY
framework: testng
browserstackLocal: $local_flag
buildName: browserstack-sample-java-web
projectName: NOW-Web-Test
percy: true
accessibility: true
platforms:
$platform_yaml
parallelsPerPlatform: $parallels
EOF

  # run Maven install first
  log_msg_to "⚙️ Running 'mvn install -DskipTests'" "$GLOBAL"
  mvn install -DskipTests >> "$log_file" 2>&1 || true

  # then run actual test suite
  log_msg_to "🚀 Running 'mvn clean test -P bstack-parallel -Dtest=OrderTest'" "$GLOBAL"
  mvn clean test -P bstack-parallel -Dtest=OrderTest >> "$log_file" 2>&1 || true


  return 0
}




setup_web_python() {
  local local_flag=$1
  local parallels=$2
  local log_file=$3

  REPO="browserstack-examples-pytest"
  TARGET_DIR="$WORKSPACE_DIR/$PROJECT_FOLDER/$REPO"

  if [ ! -d "$TARGET_DIR" ]; then
    git clone -b sdk https://github.com/BrowserStackCE/$REPO.git "$TARGET_DIR"
    log_msg_to "✅ Cloned repository: $REPO into $TARGET_DIR" "$PRE_RUN_LOG_FILE"
  else
    log_msg_to "ℹ️ Repository already exists at: $TARGET_DIR (skipping clone)" "$PRE_RUN_LOG_FILE"
  fi

  cd "$TARGET_DIR" || return 1

  validate_prereqs || return 1

  # Setup Python venv
  if [ ! -d "venv" ]; then
    python3 -m venv venv
    log_msg_to "✅ Created Python virtual environment" "$PRE_RUN_LOG_FILE"
  fi
  # shellcheck disable=SC1091
  source venv/bin/activate
  pip install -r requirements.txt >> "$log_file" 2>&1

  # Export credentials for pytest to use
  export BROWSERSTACK_USERNAME="$BROWSERSTACK_USERNAME"
  export BROWSERSTACK_ACCESS_KEY="$BROWSERSTACK_ACCESS_KEY"

  # Update YAML at root level (browserstack.yml)
  export BROWSERSTACK_CONFIG_FILE="browserstack.yml"
  platform_yaml=$(generate_web_platforms_yaml "$TEAM_PARALLELS_MAX_ALLOWED_WEB")

  cat > browserstack.yml <<EOF
userName: $BROWSERSTACK_USERNAME
accessKey: $BROWSERSTACK_ACCESS_KEY
framework: pytest
browserstackLocal: $local_flag
buildName: browserstack-sample-python-web
projectName: NOW-Web-Test
percy: true
accessibility: true
platforms:
$platform_yaml
parallelsPerPlatform: $parallels
EOF

  log_msg_to "✅ Updated root-level browserstack.yml with platforms and credentials" "$PRE_RUN_LOG_FILE"

  # Update e2e.py base URL (all occurrences)
  sed -i.bak "s|https://bstackdemo.com/|$CX_TEST_URL|g" src/test/suites/e2e.py
  log_msg_to "🌐 Updated base URL in e2e.py to: $CX_TEST_URL" "$PRE_RUN_LOG_FILE"

  # Run tests
  log_msg_to "⚠️ Running tests with local=$local_flag" "$PRE_RUN_LOG_FILE"
  browserstack-sdk pytest -s src/test/suites/e2e.py >> "$log_file" 2>&1 || true

  # Copy first 200 lines of logs for visibility
  [ -f "$log_file" ] && sed -n '1,200p' "$log_file" | while read -r l; do
    log_msg_to "web (py): $l" "$PRE_RUN_LOG_FILE"
  done

  return 0
}




setup_web_js() {
  local local_flag=$1
  local parallels=$2
  local log_file=$3

  REPO="webdriverio-browserstack"
  if [ ! -d "$REPO" ]; then
    git clone https://github.com/browserstack/$REPO
  fi
  cd "$REPO" || return 1

  validate_prereqs || return 1
  npm install >> "$log_file" 2>&1 || true

  local caps_file
  if [ "$local_flag" = true ]; then
    caps_file="conf/local-test.conf.js"
    perl -i -pe "s|const localConfig = \{\n|const localConfig = {\n  maxInstances: $TEAM_PARALLELS_MAX_ALLOWED_WEB,\n  commonCapabilities: {\n    'bstack:options': {\n      projectName: 'webdriverio-browserstack',\n      buildName: 'browserstack build',\n      buildIdentifier: '#\${BUILD_NUMBER}',\n      source: 'webdriverio:sample-master:v1.2'\n    }\n  },\n|;" "$caps_file"

    printf "\nexports.config.capabilities.forEach(function (caps) {\n  for (var i in exports.config.commonCapabilities)\n    caps[i] = { ...caps[i], ...exports.config.commonCapabilities[i]};\n});\n" >> "$caps_file"
  else
    caps_file="conf/test.conf.js"
    if sed --version >/dev/null 2>&1; then
      sed -i "s/\(maxInstances:\)[[:space:]]*[0-9]\+/\1 $TEAM_PARALLELS_MAX_ALLOWED_WEB/" "$caps_file"
    else
      sed -i '' "s/\(maxInstances:\)[[:space:]]*[0-9]\+/\1 $TEAM_PARALLELS_MAX_ALLOWED_WEB/" "$caps_file"
    fi
  fi

  local caps_json caps_js
  caps_json=$(generate_web_caps_json "$TEAM_PARALLELS_MAX_ALLOWED_WEB")
  caps_js="[${caps_json}]"

  perl -0777 -i -pe "s/capabilities:\s*\[(.*?)\]/capabilities: $caps_js/s" "$caps_file" || true

  export BROWSERSTACK_USERNAME="$BROWSERSTACK_USERNAME"
  export BROWSERSTACK_ACCESS_KEY="$BROWSERSTACK_ACCESS_KEY"
  export BROWSERSTACK_LOCAL=$local_flag

  if [ "$local_flag" = true ]; then
    npm run local > "$log_file" 2>&1 || true
  else
    npm run test > "$log_file" 2>&1 || true
  fi

  [ -f "$log_file" ] && sed -n '1,200p' "$log_file" | while read -r l; do log_msg_to "web: $l" "$GLOBAL"; done
  return 0
}

# ===== Web wrapper with retry logic (writes runtime logs to WEB_LOG_FILE) =====
setup_web() {
  log_msg_to "Starting Web setup for $TECH_STACK" "$WEB_LOG_FILE"

  local local_flag=true
  local attempt=1
  local success=false
  local log_file="$WEB_LOG_FILE"
  # don't pre-create; file will be created on first write by log_msg_to or command output redirection

  local total_parallels
  total_parallels=$(echo "$TEAM_PARALLELS_MAX_ALLOWED_WEB * $PARALLEL_PERCENTAGE" | bc | cut -d'.' -f1)
  [ -z "$total_parallels" ] && total_parallels=1
  local parallels_per_platform
  # parallels_per_platform=$(( (total_parallels + 1) / 2 ))
  parallels_per_platform=$total_parallels


  while [ "$attempt" -le 2 ]; do
    log_msg_to "[Web Setup Attempt $attempt] browserstackLocal: $local_flag" "$WEB_LOG_FILE"
    case "$TECH_STACK" in
      Java)       setup_web_java "$local_flag" "$parallels_per_platform" "$WEB_LOG_FILE" ;;
      Python)     setup_web_python "$local_flag" "$parallels_per_platform" "$WEB_LOG_FILE" ;;
      JS|JavaScript) setup_web_js "$local_flag" "$parallels_per_platform" "$WEB_LOG_FILE" ;;
      *) log_msg_to "Unknown TECH_STACK: $TECH_STACK" "$WEB_LOG_FILE"; return 1 ;;
    esac

    LOG_CONTENT=$(<"$WEB_LOG_FILE" 2>/dev/null || true)
    LOCAL_FAILURE=false
    SETUP_FAILURE=false

    for pattern in "${WEB_LOCAL_ERRORS[@]}"; do
      echo "$LOG_CONTENT" | grep -qiE "$pattern" && LOCAL_FAILURE=true && break
    done

    for pattern in "${WEB_SETUP_ERRORS[@]}"; do
      echo "$LOG_CONTENT" | grep -qiE "$pattern" && SETUP_FAILURE=true && break
    done

    if echo "$LOG_CONTENT" | grep -qiE "https://[a-zA-Z0-9./?=_-]*browserstack\.com"; then
      success=true
    fi

    if [ "$success" = true ]; then
      log_msg_to "✅ Web setup succeeded" "$WEB_LOG_FILE"
      break
    elif [ "$LOCAL_FAILURE" = true ] && [ "$attempt" -eq 1 ]; then
      local_flag=false
      attempt=$((attempt + 1))
      log_msg_to "⚠️ Web test failed due to Local tunnel error. Retrying without browserstackLocal..." "$WEB_LOG_FILE"
    elif [ "$SETUP_FAILURE" = true ]; then
      log_msg_to "❌ Web test failed due to setup error. Check logs at: $WEB_LOG_FILE" "$WEB_LOG_FILE"
      break
    else
      log_msg_to "❌ Web setup ended without success; check $WEB_LOG_FILE for details" "$WEB_LOG_FILE"
      break
    fi
  done
}

# ===== Mobile per-tech functions (write intermediate outputs into GLOBAL for visibility) =====
# setup_mobile_java() {
#   local local_flag=$1
#   local parallels=$2
#   local log_file=$3

#   REPO="testng-appium-app-browserstack"
#   if [ ! -d "$REPO" ]; then
#     git clone -b master https://github.com/browserstack/$REPO
#   fi
#   cd "$REPO" || return 1

#   validate_prereqs || return 1
#   platform_yaml=$(generate_mobile_platforms_yaml "$TEAM_PARALLELS_MAX_ALLOWED_MOBILE")

#   cat > android/testng-examples/browserstack.yml <<EOF
# userName: $BROWSERSTACK_USERNAME
# accessKey: $BROWSERSTACK_ACCESS_KEY
# framework: testng
# app: bs://sample.app
# platforms:
# $platform_yaml
# browserstackLocal: $local_flag
# buildName: browserstack-build-1
# projectName: BrowserStack Sample
# EOF

#   cd android/testng-examples || return 1
#   mvn test -P sample-test > "$log_file" 2>&1 || true
#   [ -f "$log_file" ] && sed -n '1,200p' "$log_file" | while read -r l; do log_msg_to "mobile: $l" "$GLOBAL"; done
#   return 0
# }

# setup_mobile_python() {
#   local local_flag=$1
#   local parallels=$2
#   local log_file=$3

#   REPO="python-appium-app-browserstack"
#   if [ ! -d "$REPO" ]; then
#     git clone https://github.com/browserstack/$REPO
#   fi
#   cd "$REPO" || return 1

#   validate_prereqs || return 1
#   python3 -m venv env && source env/bin/activate
#   pip3 install -r requirements.txt >> "$log_file" 2>&1 || true
#   platform_yaml=$(generate_mobile_platforms_yaml "$TEAM_PARALLELS_MAX_ALLOWED_MOBILE")

#   cat > browserstack.yml <<EOF
# userName: $BROWSERSTACK_USERNAME
# accessKey: $BROWSERSTACK_ACCESS_KEY
# framework: python
# app: bs://sample.app
# platforms:
# $platform_yaml
# browserstackLocal: $local_flag
# buildName: browserstack-build-1
# projectName: BrowserStack Sample
# EOF

#   browserstack-sdk python browserstack_sample.py > "$log_file" 2>&1 || true
#   [ -f "$log_file" ] && sed -n '1,200p' "$log_file" | while read -r l; do log_msg_to "mobile: $l" "$GLOBAL"; done
#   return 0
# }

setup_mobile_python() {
  local local_flag=$1
  local parallels=$2
  local log_file=$3

  REPO="browserstack-examples-pytest-BDD-appium"
  TARGET_DIR="$WORKSPACE_DIR/$PROJECT_FOLDER/$REPO"

  # Clone repo if not present
  if [ ! -d "$TARGET_DIR" ]; then
    git clone https://github.com/BrowserStackCE/$REPO.git "$TARGET_DIR"
    log_msg_to "✅ Cloned repository: $REPO into $TARGET_DIR" "$PRE_RUN_LOG_FILE"
  else
    log_msg_to "ℹ️ Repository already exists at: $TARGET_DIR (skipping clone)" "$PRE_RUN_LOG_FILE"
  fi

  cd "$TARGET_DIR" || return 1

  # Create & activate venv
  python3 -m venv venv
  source venv/bin/activate

  # Install dependencies
  pip install -r requirements.txt >> "$log_file" 2>&1

  # Export credentials
  export BROWSERSTACK_USERNAME="$BROWSERSTACK_USERNAME"
  export BROWSERSTACK_ACCESS_KEY="$BROWSERSTACK_ACCESS_KEY"

  # YAML config path
  export BROWSERSTACK_CONFIG_FILE="browserstack.yml"
  platform_yaml=$(generate_mobile_platforms_yaml "$TEAM_PARALLELS_MAX_ALLOWED_MOBILE")

  # Write YAML config
  cat > "$BROWSERSTACK_CONFIG_FILE" <<EOF
userName: $BROWSERSTACK_USERNAME
accessKey: $BROWSERSTACK_ACCESS_KEY
framework: pytest
browserstackLocal: $local_flag
buildName: browserstack-build-mobile
projectName: NOW-Mobile-Test
parallelsPerPlatform: $parallels
app: $APP_URL

platforms:
$platform_yaml
EOF

  log_msg_to "✅ Updated $BROWSERSTACK_CONFIG_FILE with platforms and credentials" "$PRE_RUN_LOG_FILE"

  # Log local flag status
  if [ "$local_flag" = "true" ]; then
    log_msg_to "⚠️ BrowserStack Local is ENABLED for this run." "$PRE_RUN_LOG_FILE"
  else
    log_msg_to "⚠️ BrowserStack Local is DISABLED for this run." "$PRE_RUN_LOG_FILE"
  fi  

  # Run pytest with BrowserStack SDK
  log_msg_to "🚀 Running 'browserstack-sdk pytest -s tests/test_wikipedia.py'" "$PRE_RUN_LOG_FILE"
  browserstack-sdk pytest -s tests/test_wikipedia.py >> "$log_file" 2>&1 || true

  # Copy first 200 lines of logs for visibility
  [ -f "$log_file" ] && sed -n '1,200p' "$log_file" | while read -r l; do 
    log_msg_to "mobile (python): $l" "$PRE_RUN_LOG_FILE"
  done

  deactivate
  cd "$WORKSPACE_DIR/$PROJECT_FOLDER"
  return 0
}





# setup_mobile_java() {
#   local local_flag=$1
#   local parallels=$2
#   local log_file=$3

#   REPO="browserstack-examples-appium-testng"
#   TARGET_DIR="$WORKSPACE_DIR/$PROJECT_FOLDER/$REPO"

#   if [ ! -d "$TARGET_DIR" ]; then
#     git clone https://github.com/BrowserStackCE/$REPO.git "$TARGET_DIR"
#     log_msg_to "✅ Cloned repository: $REPO into $TARGET_DIR" "$PRE_RUN_LOG_FILE"
#   else
#     log_msg_to "ℹ️ Repository already exists at: $TARGET_DIR (skipping clone)" "$PRE_RUN_LOG_FILE"
#   fi

#   cd "$TARGET_DIR" || return 1

#   validate_prereqs || return 1

#   # Export credentials for Maven
#   export BROWSERSTACK_USERNAME="$BROWSERSTACK_USERNAME"
#   export BROWSERSTACK_ACCESS_KEY="$BROWSERSTACK_ACCESS_KEY"

#   # YAML config path
#   export BROWSERSTACK_CONFIG_FILE="src/test/resources/conf/capabilities/browserstack-parallel.yml"
#   platform_yaml=$(generate_mobile_platforms_yaml "$TEAM_PARALLELS_MAX_ALLOWED_MOBILE")

#   cat > "$BROWSERSTACK_CONFIG_FILE" <<EOF
# userName: $BROWSERSTACK_USERNAME
# accessKey: $BROWSERSTACK_ACCESS_KEY
# framework: testng
# browserstackLocal: $local_flag
# buildName: browserstack-build-mobile
# projectName: NOW-Mobile-Test
# parallelsPerPlatform: $parallels
# accessibility: true
# percy: true
# app: $APP_URL
# platforms:
# $platform_yaml
# EOF

#   log_msg_to "✅ Updated $BROWSERSTACK_CONFIG_FILE with platforms and credentials" "$PRE_RUN_LOG_FILE"

#   # Log local flag status
#   if [ "$local_flag" = "true" ]; then
#     log_msg_to "⚠️ BrowserStack Local is ENABLED for this run." "$PRE_RUN_LOG_FILE"
#   else
#     log_msg_to "⚠️ BrowserStack Local is DISABLED for this run." "$PRE_RUN_LOG_FILE"
#   fi  

#   # Run Maven install first
#   log_msg_to "⚙️ Running 'mvn install -DskipTests'" "$PRE_RUN_LOG_FILE"
#   mvn install -DskipTests >> "$log_file" 2>&1 || true

#   # Then run actual test suite
#   log_msg_to "🚀 Running 'mvn clean test -P bstack-parallel -Dtest=OrderTest'" "$PRE_RUN_LOG_FILE"
#   mvn clean test -P bstack-parallel -Dtest=OrderTest >> "$log_file" 2>&1 || true

#   # Copy first 200 lines of logs for visibility
#   [ -f "$log_file" ] && sed -n '1,200p' "$log_file" | while read -r l; do 
#     log_msg_to "mobile (java): $l" "$PRE_RUN_LOG_FILE"
#   done

#   cd "$WORKSPACE_DIR/$PROJECT_FOLDER"
#   return 0
# }

setup_mobile_java() {
  local local_flag=$1
  local parallels=$2
  local log_file=$3

  REPO="browserstack-examples-appium-testng"
  TARGET_DIR="$WORKSPACE_DIR/$PROJECT_FOLDER/$REPO"

  if [ ! -d "$TARGET_DIR" ]; then
    git clone https://github.com/BrowserStackCE/$REPO.git "$TARGET_DIR"
    log_msg_to "✅ Cloned repository: $REPO into $TARGET_DIR" "$PRE_RUN_LOG_FILE"
  else
    log_msg_to "ℹ️ Repository already exists at: $TARGET_DIR (skipping clone)" "$PRE_RUN_LOG_FILE"
  fi

    # Update pom.xml → browserstack-java-sdk version to LATEST
  pom_file="$TARGET_DIR/pom.xml"
  if [ -f "$pom_file" ]; then
   sed -i.bak '/<artifactId>browserstack-java-sdk<\/artifactId>/,/<\/dependency>/ s|<version>.*</version>|<version>LATEST</version>|' "$pom_file"
    log_msg_to "🔧 Updated browserstack-java-sdk version to LATEST in pom.xml" "$PRE_RUN_LOG_FILE"
  fi

  cd "$TARGET_DIR" || return 1

  validate_prereqs || return 1

  # Export credentials for Maven
  export BROWSERSTACK_USERNAME="$BROWSERSTACK_USERNAME"
  export BROWSERSTACK_ACCESS_KEY="$BROWSERSTACK_ACCESS_KEY"

  # Update TestBase.java → switch AppiumDriver to AndroidDriver
  testbase_file=$(find src -name "TestBase.java" | head -n 1)
  if [ -f "$testbase_file" ]; then
    sed -i.bak 's/new AppiumDriver(/new AndroidDriver(/g' "$testbase_file"
    log_msg_to "🔧 Updated driver initialization in $testbase_file to use AndroidDriver" "$PRE_RUN_LOG_FILE"
  fi


  # YAML config path
  export BROWSERSTACK_CONFIG_FILE="src/test/resources/conf/capabilities/browserstack-parallel.yml"
  platform_yaml=$(generate_mobile_platforms_yaml "$TEAM_PARALLELS_MAX_ALLOWED_MOBILE")

  cat > "$BROWSERSTACK_CONFIG_FILE" <<EOF
userName: $BROWSERSTACK_USERNAME
accessKey: $BROWSERSTACK_ACCESS_KEY
framework: testng
browserstackLocal: $local_flag
buildName: browserstack-build-mobile
projectName: NOW-Mobile-Test
parallelsPerPlatform: $parallels
accessibility: true
percy: true
app: $APP_URL
platforms:
$platform_yaml
EOF

  log_msg_to "✅ Updated $BROWSERSTACK_CONFIG_FILE with platforms and credentials" "$PRE_RUN_LOG_FILE"

  # Log local flag status
  if [ "$local_flag" = "true" ]; then
    log_msg_to "⚠️ BrowserStack Local is ENABLED for this run." "$PRE_RUN_LOG_FILE"
  else
    log_msg_to "⚠️ BrowserStack Local is DISABLED for this run." "$PRE_RUN_LOG_FILE"
  fi  

  # Run Maven install first
  log_msg_to "⚙️ Running 'mvn install -DskipTests'" "$PRE_RUN_LOG_FILE"
  mvn install -DskipTests >> "$log_file" 2>&1 || true

  # Then run actual test suite
  log_msg_to "🚀 Running 'mvn clean test -P bstack-parallel -Dtest=OrderTest'" "$PRE_RUN_LOG_FILE"
  mvn clean test -P bstack-parallel -Dtest=OrderTest >> "$log_file" 2>&1 || true

  # Copy first 200 lines of logs for visibility
  [ -f "$log_file" ] && sed -n '1,200p' "$log_file" | while read -r l; do 
    log_msg_to "mobile (java): $l" "$PRE_RUN_LOG_FILE"
  done

  cd "$WORKSPACE_DIR/$PROJECT_FOLDER"
  return 0
}



setup_mobile_js() {
  local local_flag=$1
  local parallels=$2
  local log_file=$3

  REPO="webdriverio-appium-app-browserstack"
  if [ ! -d "$REPO" ]; then
    git clone -b sdk https://github.com/browserstack/$REPO
  fi
  cd "$REPO/android/" || return 1

  validate_prereqs || return 1
  npm install >> "$log_file" 2>&1 || true
  cd "examples/run-parallel-test" || return 1
  caps_file="parallel.conf.js"

  if sed --version >/dev/null 2>&1; then
    sed -i "s/\(maxInstances:\)[[:space:]]*[0-9]\+/\1 $parallels/" "$caps_file" || true
  else
    sed -i '' "s/\(maxInstances:\)[[:space:]]*[0-9]\+/\1 $parallels/" "$caps_file" || true
  fi

  caps_json=$(generate_mobile_caps_json "$parallels")
  printf "%s\n" "capabilities: $caps_json," > "$caps_file".tmp || true
  mv "$caps_file".tmp "$caps_file" || true

  export BROWSERSTACK_USERNAME="$BROWSERSTACK_USERNAME"
  export BROWSERSTACK_ACCESS_KEY="$BROWSERSTACK_ACCESS_KEY"

  npm run parallel > "$log_file" 2>&1 || true
  [ -f "$log_file" ] && sed -n '1,200p' "$log_file" | while read -r l; do log_msg_to "mobile: $l" "$GLOBAL"; done
  return 0
}

# ===== Mobile wrapper with retry logic (writes runtime logs to MOBILE_LOG_FILE) =====
setup_mobile() {
  log_msg_to "Starting Mobile setup for $TECH_STACK" "$MOBILE_LOG_FILE"

  local local_flag=true
  local attempt=1
  local success=false
  local log_file="$MOBILE_LOG_FILE"

  local total_parallels
  total_parallels=$(echo "$TEAM_PARALLELS_MAX_ALLOWED_MOBILE * $PARALLEL_PERCENTAGE" | bc | cut -d'.' -f1)
  [ -z "$total_parallels" ] && total_parallels=1
  local parallels_per_platform
  # parallels_per_platform=$(( (total_parallels + 2) / 3 ))
  parallels_per_platform=$total_parallels

  while [ "$attempt" -le 2 ]; do
    log_msg_to "[Mobile Setup Attempt $attempt] browserstackLocal: $local_flag" "$MOBILE_LOG_FILE"
    case "$TECH_STACK" in
      Java)       setup_mobile_java "$local_flag" "$parallels_per_platform" "$MOBILE_LOG_FILE" ;;
      Python)     setup_mobile_python "$local_flag" "$parallels_per_platform" "$MOBILE_LOG_FILE" ;;
      JS|JavaScript) setup_mobile_js "$local_flag" "$parallels_per_platform" "$MOBILE_LOG_FILE" ;;
      *) log_msg_to "Unknown TECH_STACK: $TECH_STACK" "$MOBILE_LOG_FILE"; return 1 ;;
    esac

    LOG_CONTENT=$(<"$MOBILE_LOG_FILE" 2>/dev/null || true)
    LOCAL_FAILURE=false
    SETUP_FAILURE=false

    for pattern in "${MOBILE_LOCAL_ERRORS[@]}"; do
      echo "$LOG_CONTENT" | grep -qiE "$pattern" && LOCAL_FAILURE=true && break
    done

    for pattern in "${MOBILE_SETUP_ERRORS[@]}"; do
      echo "$LOG_CONTENT" | grep -qiE "$pattern" && SETUP_FAILURE=true && break
    done

    if echo "$LOG_CONTENT" | grep -qiE "https://[a-zA-Z0-9./?=_-]*browserstack\.com"; then
      success=true
    fi

    if [ "$success" = true ]; then
      log_msg_to "✅ Mobile setup succeeded" "$MOBILE_LOG_FILE"
      break
    elif [ "$LOCAL_FAILURE" = true ] && [ "$attempt" -eq 1 ]; then
      local_flag=false
      attempt=$((attempt + 1))
      log_msg_to "⚠️ Mobile test failed due to Local tunnel error. Retrying without browserstackLocal..." "$MOBILE_LOG_FILE"
    elif [ "$SETUP_FAILURE" = true ]; then
      log_msg_to "❌ Mobile test failed due to setup error. Check logs at: $log_file" "$MOBILE_LOG_FILE"
      break
    else
      log_msg_to "❌ Mobile setup ended without success; check $MOBILE_LOG_FILE for details" "$MOBILE_LOG_FILE"
      break
    fi
  done
}

# ===== Orchestration: decide what to run based on TEST_TYPE and plan fetch =====
run_setup() {
  log_msg_to "Orchestration: TEST_TYPE=$TEST_TYPE, WEB_PLAN_FETCHED=$WEB_PLAN_FETCHED, MOBILE_PLAN_FETCHED=$MOBILE_PLAN_FETCHED" "$GLOBAL"

  case "$TEST_TYPE" in
    Web)
      if [ "$WEB_PLAN_FETCHED" == true ]; then
        setup_web
      else
        log_msg_to "⚠️ Skipping Web setup — Web plan not fetched" "$GLOBAL"
      fi
      ;;
    App)
      if [ "$MOBILE_PLAN_FETCHED" == true ]; then
        setup_mobile
      else
        log_msg_to "⚠️ Skipping Mobile setup — Mobile plan not fetched" "$GLOBAL"
      fi
      ;;
    Both)
      local ran_any=false
      if [ "$WEB_PLAN_FETCHED" == true ]; then
        setup_web
        ran_any=true
      else
        log_msg_to "⚠️ Skipping Web setup — Web plan not fetched" "$GLOBAL"
      fi
      if [ "$MOBILE_PLAN_FETCHED" == true ]; then
        setup_mobile
        ran_any=true
      else
        log_msg_to "⚠️ Skipping Mobile setup — Mobile plan not fetched" "$GLOBAL"
      fi
      if [ "$ran_any" == false ]; then
        log_msg_to "❌ Both Web and Mobile setup were skipped. Exiting." "$GLOBAL"
        exit 1
      fi
      ;;
    *)
      log_msg_to "❌ Invalid TEST_TYPE: $TEST_TYPE" "$GLOBAL"
      exit 1
      ;;
  esac
}

# ===== Main flow (baseline steps then run) =====
setup_workspace
ask_browserstack_credentials
ask_test_type
ask_tech_stack
validate_tech_stack_installed
# ask_user_for_test_url
fetch_plan_details

# Plan summary in pre-run log
log_msg_to "Plan summary: WEB_PLAN_FETCHED=$WEB_PLAN_FETCHED (team max=$TEAM_PARALLELS_MAX_ALLOWED_WEB), MOBILE_PLAN_FETCHED=$MOBILE_PLAN_FETCHED (team max=$TEAM_PARALLELS_MAX_ALLOWED_MOBILE)" "$GLOBAL"

# Run actual setup(s)
run_setup

# End
log_msg_to "Setup run finished" "$GLOBAL"
