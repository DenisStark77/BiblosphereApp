import cv2
import numpy as np
from flask import escape
import sys
import os
from google.cloud import storage
from tempfile import NamedTemporaryFile
import json

# Deploy with:
# gcloud functions deploy segment_shelf --runtime python37 --trigger-http
def segment_shelf(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
        <http://flask.pocoo.org/docs/1.0/api/#flask.Request>
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`
        <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>.
    """
    request_args = request.args

    if request_args and 'gcs' in request_args:
        path = request_args['gcs']
    else:
        return 'Image path missing [gcs]'

    client = storage.Client()
    # https://console.cloud.google.com/storage/browser/[bucket-id]/
    bucket_name = 'biblosphere-210106.appspot.com'
    bucket = client.get_bucket(bucket_name)

    with NamedTemporaryFile() as src:
        # path example 'images/1b2o7YjIkChyVOJK4EfbzvGpP4M2/1544380296714.jpg'
        blob = bucket.blob(path)
        blob.download_to_file(src)
        image = cv2.imread(src.name)

    contours = get_contours(image)

    response = []
    for index, c in enumerate(contours):  # default is zero
        book = crop_and_rotate(image, np.array([c[0]]), c[1])
        with NamedTemporaryFile(suffix='.jpg') as dst:
            cv2.imwrite(dst.name, book)
            bookfile = os.path.splitext(path)[0]+'/' + str(index) + '.jpg'
            blob = bucket.blob(bookfile)
            blob.upload_from_file(dst, content_type='image/jpeg')
            response.append({'gcs': 'gs://'+bucket_name+'/'+bookfile, 'contour': c[0], 'theta': c[1]})

    # Then do other things...
    # blob = bucket.blob('python-test.txt')
    # blob.upload_from_string('My text here!')
    # return 'Image stored {}'.format(escape(path))

    return json.dumps(response, indent=2)

def crop_and_rotate(img, contour, theta):
    # rotate img
    if theta > np.pi / 2.0:
        theta = theta - np.pi

    rows, cols = img.shape[0], img.shape[1]

    contour[:, :, 0] = contour[:, :, 0] * cols
    contour[:, :, 1] = contour[:, :, 1] * rows
    contour = np.int0(contour)

    x, y, w, h = cv2.boundingRect(contour)
    if x < 0:
        w = w + x
        x = 0

    if y < 0:
        h = h + y
        y = 0

    # crop source
    img_crop = img[y:y + h, x:x + w]
    contour[:, :, 0] = contour[:, :, 0] - x
    contour[:, :, 1] = contour[:, :, 1] - y

    rx = contour[0, 0, 0]
    ry = contour[0, 0, 1]

    # If top left corner out of the range use intersection with left side
    if rx < 0:
        ry = - contour[0, 0, 0]*(contour[0, 2, 1] - contour[0, 0, 1])/(contour[0, 2, 0] - contour[0, 0, 0])
        rx = 0

    M = cv2.getRotationMatrix2D((rx, ry), theta / np.pi * 180, 1)

    # rotate contour first to get target size
    contour_rot = np.int0(cv2.transform(contour, M))[0]
    contour_rot[contour_rot < 0] = 0
    x, y, w, h = cv2.boundingRect(contour_rot)

    img_rot = cv2.warpAffine(img_crop, M, (w+rx, h))

    mask = np.zeros(img_rot.shape[0:2])
    cv2.drawContours(mask, np.array([contour_rot]), -1, 255, -1)
    img_masked = np.zeros_like(img_rot)
    img_masked[mask == 255] = img_rot[mask == 255]

    # crop
    img_crop = img_masked[y:y + h, x:x + w]

    return img_crop


def get_contours(img):
    # Resize to 512 if larger
    if img.shape[1] > 512:
        ratio = 512/img.shape[1]
        img = cv2.resize(img, dsize=(0, 0), fx=ratio, fy=ratio)
    imgray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(imgray, (9, 9), 0)
    edges = cv2.Canny(blurred, 10, 200)
    lines = cv2.HoughLines(edges, rho=1, theta=1 * np.pi / 180, threshold=80)

    h, w = edges.shape[0:2]

    # Filter out np.pi * 0.15 < theta < np.pi * 0.85
    lines = lines[(np.pi * 0.15 > lines[:, 0, 1]) | (lines[:, 0, 1] > np.pi * 0.85)]

    # Get the x coordinate of the line at a middle horizontal line of the image
    # rho / np.cos(theta)) - 0.5 * h * np.tan(theta)
    order = lines[:, 0, 0] / np.cos(lines[:, 0, 1]) - 0.5 * h * np.tan(lines[:, 0, 1])

    # Sort by x coordinate on a middle horizontal line
    lines = lines[order.argsort()]

    contours = []
    first = True
    for l in lines:
        rho, theta = l[0]

        x1, y1 = int(rho / np.cos(theta)), 0
        x2, y2 = int(x1 - h * np.tan(theta)), h - 1
        rX = int((x1 + x2) / 2)

        if first:
            p_x1, p_y1, p_x2, p_y2, p_rX = x1, y1, x2, y2, rX
            first = False
        elif rX - p_rX > 10:
            contours.append([[[p_x1 / w, p_y1 / h], [x1 / w, y1 / h], [x2 / w, y2 / h], [p_x2 / w, p_y2 / h]], np.float(theta)])
            p_x1, p_y1, p_x2, p_y2, p_rX = x1, y1, x2, y2, rX

    return contours


def main():
    IMAGEFILE = "shelves/7.jpg"
    # img = imread(IMAGEFILE)
    oimg = cv2.imread(IMAGEFILE)

    contours = get_contours(oimg)

    for index, c in enumerate(contours):  # default is zero
        book = crop_and_rotate(oimg, np.array([c[0]]), c[1])
        cv2.imwrite('shelves/7-' + str(index) + '.jpg', book)


#main()

