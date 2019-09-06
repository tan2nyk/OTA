#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <sys/stat.h>
#include <signal.h>
#include <pthread.h>

char onboard_version[100] = {0}; 
char cloud_version[100] = {0}; 
bool download_complete = false;
struct stat st;
int onboard_ver;
int cloud_ver;
char md5FromInfo[40] = {0};
bool term_monitorFWUpdate_thread = false;
bool notifyBT = false;

void get_ota_ver_onboard()
{
	FILE *fp;
	fp = fopen("/etc/init.d/FirmwareVersion.txt","r");
	fseek(fp, 0, SEEK_SET);
	fread(onboard_version, 20, 1, fp);
	fclose(fp);
	//printf("Version_ %s\n", onboard_version);
	int num1 = (int)(onboard_version[10] - '0');
	int num2 = (int)(onboard_version[11] - '0');
	int num3 = (int)(onboard_version[12] - '0');
	int num4 = (int)(onboard_version[13] - '0');
	onboard_ver = num1*1000+num2*100+num3*10+num4;
}


void get_ota_ver_incloud()
{
	//Download version file from cloud	
	system("wget -N https://github.com/tan2nyk/OTA/raw/master/info --no-check-certificate");
	FILE *fp = fopen("./info","r");
	fread(cloud_version, 40, 1, fp);
	fclose(fp);
	//printf("%s\n", cloud_version);
	int num1 = (int)(cloud_version[0] - '0');
	int num2 = (int)(cloud_version[1] - '0');
	int num3 = (int)(cloud_version[2] - '0');
	int num4 = (int)(cloud_version[3] - '0');
	cloud_ver = num1*1000+num2*100+num3*10+num4;
	strncpy(md5FromInfo, cloud_version + 4, 32);
}


bool version_validate()
{
	if(cloud_ver > onboard_ver)
	{
		//indicate_user_for_update()
		return true;	
	}
	else 
		return false;
}


bool download_ota_file_from_cloud()
{	
	size_t size = 0;
	system("wget -N https://github.com/tan2nyk/OTA/raw/master/Firmware --no-check-certificate");
	stat("Firmware",&st);
	return true;
}



void updateFirmwareVersion()
{
	system("rm -rf /etc/init.d/FirmwareVersion.txt");
	FILE *fp;
	fp = fopen("/etc/init.d/FirmwareVersion.txt","w+");
	char versionStr[50] = {0};
	sprintf(versionStr, "HWTracker_%04d", cloud_ver);
	printf(versionStr);
	fwrite(versionStr, 100, 1, fp);
	fclose(fp);
}

bool verifymd5()
{
	char firmwareMD5[500] = {0};
	FILE* f = fopen("./Firmware", "rw+");
	fseek(f, -100, SEEK_END);
	long int filesize = ftell(f);
	fread(firmwareMD5, 100, 1, f);
	printf("buffer len: %d\n", strlen(firmwareMD5));
	printf("%s, %s, %d\n", firmwareMD5, md5FromInfo, filesize);
	ftruncate(f, filesize);
	int result = strcmp(firmwareMD5, md5FromInfo);
	printf("Results: %d\n", result);
	fclose(f);
	return result;
}

// void* monitorFWUpdateThread(void *ptr)
// {
// 	while(!term_monitorFWUpdate_thread)
// 	{
// 		get_ota_ver_incloud();
// 		get_ota_ver_onboard();
// 		if(version_validate())
// 		{
// 			//signal to main thread for updation process
// 		}
// 		sleep(1*60);
// 	}
// }


int main(int argc, char* argv[])
{
	bool ret = false;
	// pthread_attr_t attr;
	// pthread_t tid_monitorFWUpdate;

	// if (pthread_create(&tid_monitorFWUpdate, &attr, monitorFWUpdateThread, NULL) != 0)
	// {
	// 	printf("Create monitorFWUpdate thread error!\n");
	// 	exit(1);
	// }

	while(1)
	{
		get_ota_ver_incloud();
		get_ota_ver_onboard();
		if(version_validate())
		{
			//send notification to BT
			notifyBT = true;
			//wait 20 sec for download acknowledgement from BT

			//no ack, skip
			//if(ackreceived)
			{
				if(download_ota_file_from_cloud())
				{
					printf("FW Version: %d\n", onboard_ver);
					printf("Cloud Version: %d\n", cloud_ver);
					//md5 verification
					if(verifymd5() == 0)
					{
						updateFirmwareVersion();
						system("rm -rf HWTrackerEC25");
						system("mv ./Firmware ./HWTrackerEC25");
						system("reboot");
					}
				}
			}
		}
		notifyBT = false;
		sleep(1*60);
	}
   	return 0;
}
