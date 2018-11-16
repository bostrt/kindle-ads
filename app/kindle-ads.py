from flask import Flask, send_file, render_template
import os
import zipfile
import tempfile
import hashlib

ADVERT_FILES = {
    'ad-manifest.json',
    'banner.gif',
    'details.html',
    'screensvr.png',
    'snippet.json',
    'thumb.gif'
}
datadir = os.getenv('DATA_DIR', './data')
app = Flask(__name__)

def _build_ad():
    pass

# thanks https://stackoverflow.com/questions/3431825/generating-an-md5-checksum-of-a-file
def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def extract_adid(input):
    # TODO: Is there a better way to do this with
    result = input.split('.')[0]
    if not result:
        return None
    result = result.split('-')
    if len(result) != 2:
        return None
    result = result[1]
    if not result.isdigit():
        return None
    else:
        return result

def compress_addir(adid, timestamp, creativeid):
    tempdir = tempfile.gettempdir()
    context = dict()
    ziph = zipfile.ZipFile(os.path.join(tempdir, 'advert' + adid + '.apg'), 'w', zipfile.ZIP_DEFLATED)

    snippetjsonf = os.path.join(datadir, 'snippet.json')
    ziph.write(snippetjsonf, arcname=os.path.join(adid, 'snippet.json'))
    snippetjsonmd5 = md5(snippetjsonf)

    thumbgiff = os.path.join(datadir, 'thumb.gif')
    ziph.write(thumbgiff, arcname=os.path.join(adid, 'thumb.gif'))
    thumbgifmd5 = md5(thumbgiff)

    bannergiff = os.path.join(datadir, 'banner.gif')
    ziph.write(bannergiff, arcname=os.path.join(adid, 'banner.gif'))
    bannergifmd5 = md5(bannergiff)

    screensvrgiff = os.path.join(datadir, 'screensvr.gif')
    ziph.write(screensvrgiff, arcname=os.path.join(adid, 'screensvr.gif'))
    screensvrgifmd5 = md5(screensvrgiff)

    detailsxmlf = os.path.join(datadir, 'details.xml')
    ziph.write(detailsxmlf, arcname=os.path.join(adid, 'details.xml'))
    detailsxmlmd5 = md5(detailsxmlf)

    admanifestjsonpath = os.path.join(tempdir, 'ad-manifest.json')
    admanifestjsonf = open(admanifestjsonpath, 'w')
    admanifestjsonf.write(render_template('ad-manifest.json.tpl', \
        adid=adid, version=timestamp, creativeid=creativeid, \
        screensvrgifmd5=screensvrgifmd5, thumbgifmd5=thumbgifmd5, detailsxmlmd5=detailsxmlmd5, \
        bannergifmd5=bannergifmd5, snippetjsonmd5=snippetjsonmd5))
    admanifestjsonf.close()
    ziph.write(admanifestjsonpath, arcname='ad-manifest.json')

    ziph.close()
    return ziph.filename

@app.route('/US/<int:a>/<int:b>/<string:adid>/<string:something>/ad-<int:adid2>.<int:timestamp>.<int:creativeid>.apg', methods=['GET'])
def hello(a, b, adid, something, adid2, timestamp, creativeid):
    addirzip = compress_addir(adid, timestamp, creativeid)
    if not addirzip:
        return 'Error building ad.'

    resp = send_file(addirzip, mimetype='application/x-apg-zip')
    resp.headers['x-amz-id-2'] = 'btOnjDPjc6CFjsCDc3EwERObf8iwIbFF7gSNijBcx4uYcvtQ+gPOFuKeTXmxXPld'
    resp.headers['x-amz-request-id'] = '23B54F17F3191750'
    resp.headers['Server'] = 'AmazonS3'
    return resp

if __name__=='__main__':
     app.run(host='0.0.0.0', port=8000)
