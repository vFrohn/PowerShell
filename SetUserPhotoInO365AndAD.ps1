﻿<#
    This script job is to set or update all the company users photo in AD and in O365, and then do a cleanup in your picture folder to remove resigned users photo
    There is a limit on the photo that can be set in AD, thet photo size limit is 100k. You may need to reduce  the file size on the photes before running this scripts.

    # Made by Christian Frohn // https://github.com/vFrohn // https://www.linkedin.com/in/frohn/


    * DISCLAIMER OF WARRANTIES:
    *
    * THE SOFTWARE PROVIDED HEREUNDER IS PROVIDED ON AN "AS IS" BASIS, WITHOUT
    * ANY WARRANTIES OR REPRESENTATIONS EXPRESS, IMPLIED OR STATUTORY; INCLUDING,
    * WITHOUT LIMITATION, WARRANTIES OF QUALITY, PERFORMANCE, NONINFRINGEMENT,
    * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  NOR ARE THERE ANY
    * WARRANTIES CREATED BY A COURSE OR DEALING, COURSE OF PERFORMANCE OR TRADE
    * USAGE.  FURTHERMORE, THERE ARE NO WARRANTIES THAT THE SOFTWARE WILL MEET
    * YOUR NEEDS OR BE FREE FROM ERRORS, OR THAT THE OPERATION OF THE SOFTWARE
    * WILL BE UNINTERRUPTED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
    * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
    * EXEMPLARY, OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY THEORY OF
    * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
    * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    *

#>

#User specifed 
$UserPictureFolder = "" #Where all the user photos is stored
$UserResignedFolder = "" #Where you want to move the resigned users photos to.
$TempPhoto = "" #The location of the temporay photo that need to be set if no picture exists
$OUs = "" #Users OU


$Users = foreach ($ADuser in $OUs) { Get-ADUser -Filter * -Properties * -SearchBase $ADuser | select samaccountname}
$StaffPictures = Get-ChildItem -File $UserPictureFolder| select BaseName


#Setting Userphoto in Active Directory

Foreach ($User in $Users) 
{
    $Picture=$($StaffPictures.BaseName)
    $Employee=$($User.samaccountname)

    if ($Picture -eq $Employee)
        {
            #Set-ADUser $Employee -Replace @{thumbnailPhoto=([byte[]](Get-Content "$ADphotofolderTemp\$($Employee).jpg" -Encoding byte))} 
            Write-Host -ForegroundColor Green "Setting Active Directory userphoto for:" $Employee
        
        }
    elseif ($Picture -ne $Employee)
        {
            #Set-ADUser $Employee -Replace @{thumbnailPhoto=([byte[]](Get-Content "$TempPhoto" -Encoding byte))}
            Write-Host -ForegroundColor Yellow "Setting temporary userphoto in Active Directory for:" $Employee
        }
}



#Setting UserPhoto in Microsoft Office 365

Foreach ($User in $Users) 
{
    $Picture=$($StaffPictures.BaseName)
    $Employee=$($User.samaccountname)

    if ($Picture -eq $Employee)
    {
        Set-UserPhoto $Employee -PictureData ([System.IO.File]::ReadAllBytes("$PictureFolder\$($Employee).jpg")) -Confirm:$false 
        Write-Host -ForegroundColor Cyan "Setting userphoto in O365 for:" $Employee
    }
    elseif ($Picture -ne $Employee)
    {
        #Set-UserPhoto $Employee -PictureData ([System.IO.File]::ReadAllBytes($TempPhoto)) -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Magenta "Setting temporary userphoto in O365 for:" $Employee
    }
}



#Cleanup picture folder

Foreach ($StaffPicture in $StaffPictures)
{

    $File=$($StaffPicture.BaseName)
    $User = foreach ($ADuser in $OUs) { Get-ADUser -Properties * -SearchBase $ADuser -Filter "SamAccountName -eq '$File'" }
   
    If ($User -eq $Null) 
    { 
        #Move-Item "$PictureFolder\$($File).jpg" "$ResignedFolder"
        Write-Host -ForegroundColor Gray $File "Not found - Moving photo to resgined folder"
    }
}

