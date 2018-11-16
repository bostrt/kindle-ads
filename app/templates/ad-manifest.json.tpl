{
    "ad-units": [
        {
            "ad-id": "{{ adid }}",
            "start": "Tue, 1 Aug 2017 04:00:00 GMT",
            "end": "Wed, 1 Jan 2025 04:59:00 GMT",
            "remove-after": "Wed, 1 Jan 2025 04:59:00 GMT",
            "version": {{ version }},
            "ad-type": "DYNAMIC_BACKUP",
            "categoryId": 100,
            "cap-duration": 24,
            "cap-count": 501,
            "features": [

            ],
            "assets": [
                {
                    "filename": "screensvr.gif",
                    "checksum": "{{ screensvrgifmd5 }}",
                    "creative-id": "{{ creativeid }}"
                },
                {
                    "filename": "thumb.gif",
                    "checksum": "{{ thumbgifmd5 }}",
                    "creative-id": "{{ creativeid }}"
                },
                {
                    "filename": "details.xml",
                    "checksum": "{{ detailsxmlmd5 }}",
                    "creative-id": "{{ creativeid }}"
                },
                {
                    "filename": "banner.gif",
                    "checksum": "{{ bannergifmd5 }}",
                    "creative-id": "{{ creativeid }}"
                },
                {
                    "filename": "snippet.json",
                    "checksum": "{{ snippetjsonmd5 }}",
                    "creative-id": "{{ creativeid }}"
                }
            ],
            "priority": 1,
            "vso-order": 0
        }
    ],
    "encoding": "ad-units-package-1.0"
}
