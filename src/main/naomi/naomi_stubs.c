/***************************************************************************
    NAOMI: functions the Dreamcast libraries expect but the NAOMI does not
    have (KallistiOS leaves out the Dreamcast BIOS services on the NAOMI).
***************************************************************************/

/* SDL2's Dreamcast video driver asks the console's flash ROM for its region
   to choose 50 or 60 Hz. The NAOMI has no such flash ROM and always runs at
   60 Hz (31 kHz VGA on the cabinet monitor): answer "US" (60 Hz). */
int flashrom_get_region(void)
{
    return 2;   /* FLASHROM_REGION_US */
}
