//------------------------------------------------
// Sample.h
//
//   author: Kipernal
//------------------------------------------------
#pragma once

class Sample
{
public:
	std::string name;
	std::vector<byte> data;
	unsigned short loopPoint;
	bool exists;
	bool important;			// If a sample is important, then is should never be excluded.

	//--------------------------------------
	// Funcs
	//--------------------------------------
	Sample(void);
	void setMD5sum();
	const byte* getMD5sum() const;
	int cmpMD5sum(Sample&);
					// Otherwise, it's only used if the song has an instrument or $E5/$F3 command that is using it.
private:
	byte md5digest[16];
};

