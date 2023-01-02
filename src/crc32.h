#include <stdint.h>
#include <stddef.h>

/*************************************************************************************************/
/*!
 *  \brief  Calculate the CRC32 value for the given buffer.
 *
 *  \param  data    Pointer to the data.
 *  \param  n_bytes Number of bytes in the buffer.
 *  \param  crc     Pointer to store the result.
 *
 *  \return None.
 */
/*************************************************************************************************/
void crc32(const void *data, size_t n_bytes, uint32_t *crc);