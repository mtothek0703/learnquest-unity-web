#!/usr/bin/env python3
"""Offline, standard-library tests for immutable GitHub Pages snapshots."""
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import preserve_legacy_pages as archive


class PreservePagesTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.env = patch.dict(os.environ, {"SITE_ROOT": str(self.root)})
        self.env.start()
        self.addCleanup(self.env.stop)
        self.versions = patch.object(archive, "VERSIONS", ("skyway-v15", "skyway-v16", "skyway-v17", "skyway-v18", "skyway-v19", "skyway-v20", "skyway-v21"))
        self.versions.start()
        self.addCleanup(self.versions.stop)

    def mock_download(self, url, destination, missing=()):
        relative = url.removeprefix(archive.BASE)
        if relative in missing:
            return False
        if relative.rsplit("/", 1)[-1] not in archive.REQUIRED + ("build.txt",):
            return False
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(("historical:" + relative).encode())
        return True

    def test_preserves_all_versions_and_original_build_markers(self):
        with patch.object(archive, "download", side_effect=self.mock_download):
            archive.main()
        manifest = json.loads((self.root / "preserved-versions.json").read_text())
        self.assertEqual(set(manifest), {"skyway-v15", "skyway-v16", "skyway-v17", "skyway-v18", "skyway-v19", "skyway-v20", "skyway-v21"})
        for version in manifest:
            self.assertEqual(
                (self.root / version / "build.txt").read_text(),
                "historical:" + version + "/build.txt",
            )
            self.assertTrue((self.root / version / "index.wasm").is_file())
            self.assertEqual(manifest[version]["missing_required"], [])

    def test_missing_historical_asset_blocks_deployment(self):
        def download(url, destination):
            return self.mock_download(url, destination, ("skyway-v15/index.wasm",))
        with patch.object(archive, "download", side_effect=download):
            with self.assertRaisesRegex(RuntimeError, "skyway-v15 is incomplete"):
                archive.main()
        self.assertFalse((self.root / "preserved-versions.json").exists())

    def test_missing_v17_blocks_deployment(self):
        def download(url, destination):
            return self.mock_download(url, destination, ("skyway-v17/index.html",))
        with patch.object(archive, "download", side_effect=download):
            with self.assertRaisesRegex(RuntimeError, "skyway-v17 is missing"):
                archive.main()
        self.assertFalse((self.root / "preserved-versions.json").exists())

    def test_missing_v18_blocks_deployment(self):
        def download(url, destination):
            return self.mock_download(url, destination, ("skyway-v18/index.html",))
        with patch.object(archive, "download", side_effect=download):
            with self.assertRaisesRegex(RuntimeError, "skyway-v18 is missing"):
                archive.main()
        self.assertFalse((self.root / "preserved-versions.json").exists())

    def test_missing_v19_blocks_deployment(self):
        def download(url, destination):
            return self.mock_download(url, destination, ("skyway-v19/index.html",))
        with patch.object(archive, "download", side_effect=download):
            with self.assertRaisesRegex(RuntimeError, "skyway-v19 is missing"):
                archive.main()
        self.assertFalse((self.root / "preserved-versions.json").exists())

    def test_missing_v20_blocks_deployment(self):
        def download(url, destination):
            return self.mock_download(url, destination, ("skyway-v20/index.html",))
        with patch.object(archive, "download", side_effect=download):
            with self.assertRaisesRegex(RuntimeError, "skyway-v20 is missing"):
                archive.main()
        self.assertFalse((self.root / "preserved-versions.json").exists())

    def test_missing_v21_blocks_deployment(self):
        def download(url, destination):
            return self.mock_download(url, destination, ("skyway-v21/index.html",))
        with patch.object(archive, "download", side_effect=download):
            with self.assertRaisesRegex(RuntimeError, "skyway-v21 is missing"):
                archive.main()
        self.assertFalse((self.root / "preserved-versions.json").exists())

    def test_missing_current_v16_blocks_deployment(self):
        def download(url, destination):
            return self.mock_download(url, destination, ("skyway-v16/index.html",))
        with patch.object(archive, "download", side_effect=download):
            with self.assertRaisesRegex(RuntimeError, "skyway-v16 is missing"):
                archive.main()
        self.assertFalse((self.root / "preserved-versions.json").exists())


if __name__ == "__main__":
    unittest.main()
