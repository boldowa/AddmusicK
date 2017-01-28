//------------------------------------------------
// Sample.cpp
//
//   author: boldowa(6646)
//------------------------------------------------
#include "gstdafx.hpp"

#include "Sample.h"
#include "mdconf.h"
#include "md5.h"

//--------------------------------------
// Constructor
//--------------------------------------
Sample::Sample(void)
	: loopPoint(0),
	  exists(false),
	  important(true)
{
}

//--------------------------------------
// Generate MD5 sum from BRR data
//--------------------------------------
void Sample::setMD5sum()
{
	MD5_CTX context;

	// Init
	MD5Init(&context);

	// Calculate checksum
	MD5Update(&context, reinterpret_cast<byte *>(&loopPoint), sizeof(unsigned short));	// loop point
	MD5Update(&context, &data[0], data.size());			// BRR data

	// Finalize
	MD5Final(md5digest, &context);
}

//--------------------------------------
// Generate MD5 sum from BRR data
//--------------------------------------
const byte* Sample::getMD5sum() const
{
	return this->md5digest;
}

//--------------------------------------
// Compare MD5 sum
//   * returns *
//      0 : equal
//     !0 : not equal
//--------------------------------------
int Sample::cmpMD5sum(Sample &cmp)
{
	return memcmp(this->md5digest, cmp.getMD5sum(), sizeof(byte)*16);
}

