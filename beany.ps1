Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Start-Process "Narrator.exe"
$xpError = New-Object System.Media.SoundPlayer ""

# ============================================================
# BEAN CHAOS CONFIGURATION
# ============================================================

# Replace these with DIRECT image URLs.
$BeanImages = @(
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGGgCu_5rFU-LVw5XH0-GfBux33aPFsm7iYxBkG4kI5w&s=10",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRnCPKc3OnFtPMpuEfQxjCS2nvWXxLb0zYd6FKUceildQ&s=10",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRm9j9ipuX44wghz-zUgV_OTT2_Wa7Ccy1GuHstk6e7ew&s=10",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqmApCMGXBbAIyG5pfWHsYh-wFJelqb4_gu63KB0TZYg&s=10"

)

$RandomMessages = @(
    "3 days until Mario steals your liver",
    "Russia is on your computer now, comrade",
    "THE BEANS ARE APPROACHING",
    "You have been selected for bean duty",
    "This is not a drill. There are beans.",
    "Downloading additional beans...",
    "Deploying tactical beans",
    "Bean containment has failed",
    "The beans know where you live",
    "Congratulations! You have beans."
)

# How long the actual chaos lasts.
$ChaosDurationSeconds = 450000000

# ============================================================
# GLOBAL STATE
# ============================================================

$script:Running = $true
$script:Windows = New-Object System.Collections.ArrayList

# ============================================================
# HELPER: RANDOM SCREEN POSITION
# ============================================================

function Get-RandomPosition {
    param(
        [int]$Width,
        [int]$Height
    )

    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea

    $maxX = [Math]::Max(0, $screen.Width - $Width)
    $maxY = [Math]::Max(0, $screen.Height - $Height)

    return @{
        X = Get-Random -Minimum 0 -Maximum ($maxX + 1)
        Y = Get-Random -Minimum 0 -Maximum ($maxY + 1)
    }
}

# ============================================================
# HELPER: REGISTER WINDOW
# ============================================================

function Register-Window {
    param($Window)

    [void]$script:Windows.Add($Window)

    $Window.Add_FormClosed({
        [void]$script:Windows.Remove($this)
    })
}

# ============================================================
# STOP EVERYTHING
# ============================================================

function Stop-BeanChaos {

    $script:Running = $false

    foreach ($window in @($script:Windows)) {
        try {
            $window.Close()
        }
        catch {}
    }

    [System.Media.SystemSounds]::Asterisk.Play()
}

# ============================================================
# GLOBAL ESCAPE HANDLER
# ============================================================

$mainContext = New-Object System.Windows.Forms.ApplicationContext

# ============================================================
# COUNTDOWN WINDOW
# ============================================================

$countdown = New-Object System.Windows.Forms.Form

$countdown.Text = "TOTALLY NORMAL WINDOWS COUNTDOWN"
$countdown.Size = New-Object System.Drawing.Size(600,350)
$countdown.StartPosition = "CenterScreen"
$countdown.TopMost = $true
$countdown.FormBorderStyle = "FixedDialog"
$countdown.MaximizeBox = $false
$countdown.MinimizeBox = $false
$countdown.KeyPreview = $true

$countLabel = New-Object System.Windows.Forms.Label
$countLabel.Dock = "Fill"
$countLabel.TextAlign = "MiddleCenter"
$countLabel.Font = New-Object System.Drawing.Font(
    "Arial",
    28,
    [System.Drawing.FontStyle]::Bold
)

$countdown.Controls.Add($countLabel)



$seconds = 10

$countTimer = New-Object System.Windows.Forms.Timer
$countTimer.Interval = 1000

$countTimer.Add_Tick({

    if (-not $script:Running) {
        $countTimer.Stop()
        return
    }

    $seconds--

    if ($seconds -gt 30) {

        $countLabel.Text = @"
Something completely normal
is going to happen in...

$seconds
"@

    }
    elseif ($seconds -gt 10) {

        $countLabel.Text = @"
WARNING

THE BEANS AWAKEN IN

$seconds
"@

        if ($seconds % 5 -eq 0) {
            [System.Media.SystemSounds]::Exclamation.Play()
        }

    }
    elseif ($seconds -gt 0) {

        $countLabel.Text = @"
!!! BEAN DEPLOYMENT !!!

$seconds

SECONDS

REMAINING
"@

        [System.Media.SystemSounds]::Beep.Play()

    }
    else {

        $countTimer.Stop()
        $countdown.Close()
    }
})

$countdown.Add_Shown({

    $countLabel.Text = @"
Something completely normal
is going to happen in...

60
"@

    $countTimer.Start()
})

Register-Window $countdown

[void]$countdown.ShowDialog()

if (-not $script:Running) {
    exit
}

# ============================================================
# BEAN POPUP
# ============================================================

function Show-BeanPopup {

    if (-not $script:Running) {
        return
    }

    $window = New-Object System.Windows.Forms.Form

    $window.Text = "BEANS"
    $window.Size = New-Object System.Drawing.Size(420,420)
    $window.TopMost = $true
    $window.FormBorderStyle = "FixedSingle"
    $window.MaximizeBox = $false
    $window.MinimizeBox = $true
    $window.KeyPreview = $true

    $position = Get-RandomPosition `
        -Width 420 `
        -Height 420

    $window.Location = New-Object System.Drawing.Point(
        $position.X,
        $position.Y
    )

    $picture = New-Object System.Windows.Forms.PictureBox

    $picture.Dock = "Fill"
    $picture.SizeMode = "Zoom"

    $url = Get-Random -InputObject $BeanImages

    try {

        $client = New-Object System.Net.WebClient

        $bytes = $client.DownloadData($url)

        $stream = New-Object System.IO.MemoryStream(,$bytes)

        $picture.Image = [System.Drawing.Image]::FromStream($stream)

    }
    catch {

        $picture.BackColor = [System.Drawing.Color]::Black

        $label = New-Object System.Windows.Forms.Label

        $label.Dock = "Fill"
        $label.TextAlign = "MiddleCenter"
        $label.ForeColor = [System.Drawing.Color]::White
        $label.Font = New-Object System.Drawing.Font(
            "Arial",
            22,
            [System.Drawing.FontStyle]::Bold
        )

        $label.Text = @"
BEAN IMAGE
FAILED

THIS IS
UNACCEPTABLE
"@

        $window.Controls.Add($label)
    }

    $window.Controls.Add($picture)

    $window.Add_KeyDown({

        if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
            $window.Close()
        }

    })

    Register-Window $window

    $window.Show()

    [System.Media.SystemSounds]::Asterisk.Play()
}

# ============================================================
# RANDOM MESSAGE POPUP
# ============================================================

function Show-RandomMessage {

    if (-not $script:Running) {
        return
    }

    $window = New-Object System.Windows.Forms.Form

    $window.Text = "IMPORTANT SYSTEM MESSAGE"
    $window.Size = New-Object System.Drawing.Size(500,220)
    $window.TopMost = $true
    $window.StartPosition = "Manual"
    $window.KeyPreview = $true

    $position = Get-RandomPosition `
        -Width 500 `
        -Height 220

    $window.Location = New-Object System.Drawing.Point(
        $position.X,
        $position.Y
    )

    $label = New-Object System.Windows.Forms.Label

    $label.Dock = "Fill"
    $label.TextAlign = "MiddleCenter"
    $label.Font = New-Object System.Drawing.Font(
        "Arial",
        17,
        [System.Drawing.FontStyle]::Bold
    )

    $label.Text = Get-Random -InputObject $RandomMessages

    $window.Controls.Add($label)

    $window.Add_KeyDown({

        if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
            $window.Close()
        }

    })

    Register-Window $window

    $window.Show()

    [System.Media.SystemSounds]::Exclamation.Play()
}

# ============================================================
# MASTER CHAOS CONTROLLER
# ============================================================

$startTime = Get-Date

$nextBean = Get-Date
$nextMessage = (Get-Date).AddMilliseconds(
    (Get-Random -Minimum 500 -Maximum 2000)
)

$chaosTimer = New-Object System.Windows.Forms.Timer

$chaosTimer.Interval = 100

$chaosTimer.Add_Tick({

    if (-not $script:Running) {

        $chaosTimer.Stop()

        foreach ($window in @($script:Windows)) {
            try {
                $window.Close()
            }
            catch {}
        }

        return
    }

    $elapsed = ((Get-Date) - $startTime).TotalSeconds

    # Finished.
    if ($elapsed -ge $ChaosDurationSeconds) {

        $chaosTimer.Stop()

        foreach ($window in @($script:Windows)) {
            try {
                $window.Close()
            }
            catch {}
        }

        return
    }

    # --------------------------------------------------------
    # Bean spawning
    # --------------------------------------------------------

    if ((Get-Date) -ge $nextBean) {

        Show-BeanPopup
        Start-Process calc

        # Starts slower, becomes increasingly ridiculous.
        $delay = Get-Random `
            -Minimum 0 `
            -Maximum 100

        $nextBean = (Get-Date).AddMilliseconds($delay)
    }

    # --------------------------------------------------------
    # Random messages
    # --------------------------------------------------------

    if ((Get-Date) -ge $nextMessage) {

        Show-RandomMessage

        $delay = Get-Random `
            -Minimum 2000 `
            -Maximum 3000

        $nextMessage = (Get-Date).AddMilliseconds($delay)
    }

    [System.Windows.Forms.Application]::DoEvents()
})

$chaosTimer.Start()

[System.Windows.Forms.Application]::Run()

# ============================================================
# CLEANUP
# ============================================================

foreach ($window in @($script:Windows)) {
    try {
        $window.Dispose()
    }
    catch {}
}

Write-Host ""
Write-Host "THE BEAN INCIDENT HAS CONCLUDED."
Write-Host "No computers were permanently beaned."