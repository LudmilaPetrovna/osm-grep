#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdarg.h>
#include <zlib.h>
#include <time.h>

#ifdef _WIN32
#include <winsock2.h>
#else
#include <netinet/in.h>
#endif

#include "osm.h"

int use_gzip=0;

uint64_t tl_x=0;
uint64_t tl_y=0;
std::string str;
std::string strkey;
std::string strval;

typedef struct{
char *name;
int name_len;
char *value;
int value_len;
}NEEDTAG;

#define NEEDTAG_MAX (500)

NEEDTAG needtag[NEEDTAG_MAX];
int needtag_count=0;

void load_needtag(char *filename){
FILE *in=fopen(filename,"r");
char n[256],v[256],line[256];
char *val;
while(!feof(in)){
if(!fgets(line,sizeof(line),in)){break;}

n[0]=0;
v[0]=0;

strcpy(n,strtok(line,(const char*)"=\r\n"));
val=strtok(NULL,(const char*)"=\r\n");
if(val){
strcpy(v,val);
}
needtag[needtag_count].name=strdup(n);
needtag[needtag_count].name_len=strlen(n);
needtag[needtag_count].value=strdup(v);
needtag[needtag_count].value_len=strlen(v);
needtag_count++;
}

fclose(in);
}

char outchunk[16384];
char zipchunk[163840];

char buffer[OSMPBF::max_uncompressed_blob_size];
char unpack_buffer[OSMPBF::max_uncompressed_blob_size];
OSMPBF::BlobHeader blobheader;
OSMPBF::Blob blob;
OSMPBF::HeaderBlock headerblock;
OSMPBF::PrimitiveBlock primblock;

// prints a formatted message to stdout, optionally color coded
void msg(const char* format, int color, va_list args) {
    vfprintf(stdout, format, args);
    fprintf(stdout, "\x1b[0m\n");
}

// prints a formatted message to stdout, color coded to red
void err(const char* format, ...) {
    va_list args;
    va_start(args, format);
    msg(format, 31, args);
    va_end(args);
    exit(1);
}

// prints a formatted message to stdout, color coded to yellow
void warn(const char* format, ...) {
    va_list args;
    va_start(args, format);
    msg(format, 33, args);
    va_end(args);
}

// prints a formatted message to stdout, color coded to green
void info(const char* format, ...) {
    va_list args;
    va_start(args, format);
    msg(format, 32, args);
    va_end(args);
}

// prints a formatted message to stdout, color coded to white
void debug(const char* format, ...) {
    va_list args;
    va_start(args, format);
    msg(format, 37, args);
    va_end(args);
}

// application main method
int main(int argc, char *argv[]) {

    FILE *fp = fopen(argv[1], "rb");
    if (!fp) {
        err("can't open file '%s'", argv[1]);
    }


FILE *output;
if(argc==4){
if(strstr(argv[3],".gz")){
use_gzip=1;
}
output=fopen(argv[3],"wb");
fprintf(stderr,"Saving file as \"%s\" with %s gzip\n",argv[3],use_gzip?"SUPPORT":"NO");
} else {
output=stdout;
fprintf(stderr,"Output to terminal\n");
}


z_stream defstream;
defstream.zalloc = Z_NULL;
defstream.zfree = Z_NULL;
defstream.opaque = Z_NULL;
//deflateInit(&defstream, Z_BEST_COMPRESSION);
deflateInit2(&defstream,9,Z_DEFLATED,15+16,9,Z_DEFAULT_STRATEGY);


load_needtag(argv[2]);



    // read while the file has not reached its end
    while (!feof(fp)) {
        // storage of size, used multiple times
        int32_t sz;

        // read the first 4 bytes of the file, this is the size of the blob-header
static int last_time_progress=0;
int now=time(0);
if(now!=last_time_progress){
last_time_progress=now;
fprintf(stderr,"\rReading file at %llu...\n",(uint64_t)ftell(fp));
}

        if (fread(&sz, sizeof(sz), 1, fp) != 1) {
            break; // end of file reached
        }

        // convert the size from network byte-order to host byte-order
        sz = ntohl(sz);

        // ensure the blob-header is smaller then MAX_BLOB_HEADER_SIZE
        if (sz > OSMPBF::max_blob_header_size) {
            err("blob-header-size is bigger then allowed (%u > %u)", sz, OSMPBF::max_blob_header_size);
        }

        // read the blob-header from the file
        if (fread(buffer, sz, 1, fp) != 1) {
            err("unable to read blob-header from file");
        }

        // parse the blob-header from the read-buffer
        if (!blobheader.ParseFromArray(buffer, sz)) {
            err("unable to parse blob header");
        }

        sz = blobheader.datasize();

        // ensure the blob is smaller then MAX_BLOB_SIZE
        if (sz > OSMPBF::max_uncompressed_blob_size) {
            err("blob-size is bigger then allowed (%u > %u)", sz, OSMPBF::max_uncompressed_blob_size);
        }

        // read the blob from the file
        if (fread(buffer, sz, 1, fp) != 1) {
            err("unable to read blob from file");
        }

        // parse the blob from the read-buffer
        if (!blob.ParseFromArray(buffer, sz)) {
            err("unable to parse blob");
        }

        // tell about the blob-header

        // set when we find at least one data stream
        bool found_data = false;

        // if the blob has uncompressed data
        if (blob.has_raw()) {
            found_data = true;
            sz = blob.raw().size();
            memcpy(unpack_buffer, buffer, sz);
        }

        // if the blob has zlib-compressed data
        if (blob.has_zlib_data()) {
            // issue a warning if there is more than one data steam, a blob may only contain one data stream
            found_data = true;

            // the size of the compressesd data
            sz = blob.zlib_data().size();

            z_stream z;
            z.next_in   = (unsigned char*) blob.zlib_data().c_str();
            z.avail_in  = sz;
            z.next_out  = (unsigned char*) unpack_buffer;
            z.avail_out = blob.raw_size();
            z.zalloc    = Z_NULL;
            z.zfree     = Z_NULL;
            z.opaque    = Z_NULL;

            if (inflateInit(&z) != Z_OK) {
                err("  failed to init zlib stream");
            }
            if (inflate(&z, Z_FINISH) != Z_STREAM_END) {
                err("  failed to inflate zlib stream");
            }
            if (inflateEnd(&z) != Z_OK) {
                err("  failed to deinit zlib stream");
            }

            sz = z.total_out;
        }

        // if the blob has lzma-compressed data
        if (blob.has_lzma_data()) {
            found_data = true;
            err("  lzma-decompression is not supported");
        }

        // check we have at least one data-stream
        if (!found_data) {
            err("  does not contain any known data stream");
        }

        // switch between different blob-types
        if (blobheader.type() == "OSMHeader") {
            // tell about the OSMHeader blob

            // parse the HeaderBlock from the blob
            if (!headerblock.ParseFromArray(unpack_buffer, sz)) {
                err("unable to parse header block");
            }

            // tell about the bbox
            if (headerblock.has_bbox()) {
                OSMPBF::HeaderBBox bbox = headerblock.bbox();
tl_x=bbox.left();
tl_y=bbox.bottom();
            }

        } else if (blobheader.type() == "OSMData") {

            // parse the PrimitiveBlock from the blob
            if (!primblock.ParseFromArray(unpack_buffer, sz)) {
                err("unable to parse primitive block");
            }
OSMPBF::StringTable st=primblock.stringtable();

            // iterate over all PrimitiveGroups
            for (int i = 0, l = primblock.primitivegroup_size(); i < l; i++) {
                // one PrimitiveGroup from the the Block
                OSMPBF::PrimitiveGroup pg = primblock.primitivegroup(i);



                // tell about dense nodes
                if (pg.has_dense()) {
OSMPBF::DenseNodes de=pg.dense();
int keycount=de.keys_vals_size();
int64_t prev_lat=0,prev_lon=0,prev_id=0;
int de_size=pg.dense().id_size();
int q;
int gran=primblock.granularity();

int is_marine;

int keypos=0;
int curkey;
int spos=0;

int chlen=needtag_count;
int ch;

char *tagname,*tagval;

for(q=0;q<de_size;q++){
prev_lat+=de.lat(q)*gran;
prev_lon+=de.lon(q)*gran;
prev_id+=de.id(q);



is_marine=0;
curkey=keypos;

while(keypos<keycount && de.keys_vals(keypos)){
strkey=st.s(de.keys_vals(keypos++));
strval=st.s(de.keys_vals(keypos++));
for(ch=0;ch<chlen;ch++){

//printf("need tag %d: %s=[%s]\n",ch,needtag[ch].name,needtag[ch].value);
if(memcmp(strkey.c_str(),needtag[ch].name,needtag[ch].name_len)==0 && (needtag[ch].value_len==0 || strcmp(strval.c_str(),needtag[ch].value)==0)){
is_marine++;
}
}
}
keypos++;

if(is_marine){
keypos=curkey;
spos=0;
spos+=sprintf(outchunk,"lat/lon %lld/%lld: ",prev_lat,prev_lon);
while(keypos<keycount && de.keys_vals(keypos)){
strkey=st.s(de.keys_vals(keypos++));
strval=st.s(de.keys_vals(keypos++));
//if(memcmp(strkey.c_str(),"seamark",7)==0){continue;}
spos+=sprintf(outchunk+spos,"%s=%s;; ",strkey.c_str(),strval.c_str());
}
keypos++; // null separator

spos+=sprintf(outchunk+spos,"\n");

if(use_gzip){
defstream.next_in=(Bytef*)outchunk;
defstream.avail_in=spos;
defstream.next_out=(Bytef*)zipchunk;
defstream.avail_out=sizeof(zipchunk);
deflate(&defstream,Z_NO_FLUSH);
if(defstream.avail_out!=sizeof(zipchunk)){
fwrite(zipchunk,1,sizeof(zipchunk)-defstream.avail_out,output);
}
} else {
fwrite(outchunk,1,spos,output);
}


}


}




                }

            }
        }

        else {
            // unknown blob type
            warn("  unknown blob type: %s", blobheader.type().c_str());
        }
    }

    // close the file pointer
    fclose(fp);

if(use_gzip){
fprintf(stderr,"FLUSHING\n\n");
defstream.next_in=(Bytef*)outchunk;
defstream.avail_in=0;
defstream.next_out=(Bytef*)zipchunk;
defstream.avail_out=sizeof(zipchunk);
deflate(&defstream, Z_FINISH);
deflateEnd(&defstream);
if(defstream.avail_out!=sizeof(zipchunk)){
fwrite(zipchunk,1,sizeof(zipchunk)-defstream.avail_out,output);
}
}

fclose(output);

    // clean up the protobuf lib
    google::protobuf::ShutdownProtobufLibrary();
}

