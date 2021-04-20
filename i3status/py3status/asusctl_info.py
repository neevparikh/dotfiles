# -*- coding: utf-8 -*-
"""
Module that reports asusctl info

Configuration parameters:
    format: Format to use
        (default  " {graphics_mode} {graphics_power} {profile} {turbo_enabled} {fan_preset} ")

Format placeholders:
    {graphics_mode}: Graphics mode of system (one of 'integrated', 'hybrid', 'nvidia')
    {graphics_power}: Power status of nvidia card
    {profile}: Which profile is active
    {turbo_enabled}: Whether turbo in cpu is active or not
    {fan_preset}: What fan mode is active
"""

import json

preset_to_name = {
        '0': 'normal',
        '1': 'boost',
        '2': 'silent',
    }

bad_strs = [
        'Active profile:',
        'Current graphics mode:',
        'Current power status:',
        'Active profile:',
        '\n',
        '\x1b[32m',
        '\x1b[31m',
        '\x1b[30m',
        '\x1b[0m',
    ]


class Py3status:
    format = " {graphics_mode} {graphics_power} {profile} {turbo_enabled} {fan_preset} "
    cached_until = 60

    @staticmethod
    def _sanitize_output(s):
        for bad_str in bad_strs:
            s = s.replace(bad_str, '')
        s = s.strip()
        return s

    def _get_asusctl_active_data(self):
        data = self._sanitize_output(self.py3.command_output("asusctl profile --active-data"))
        data = json.loads(data)
        return data

    def _graphics_mode(self):
        return self._sanitize_output(self.py3.command_output("asusctl graphics --get"))

    def _graphics_power_status(self):
        return self._sanitize_output(self.py3.command_output("asusctl graphics --pow"))

    def _profile_status(self):
        return self._sanitize_output(self.py3.command_output("asusctl profile --active-name")).replace('"', '')

    def _profile_turbo(self):
        data = self._get_asusctl_active_data()
        return data['turbo']

    def _profile_fan_preset(self):
        data = self._get_asusctl_active_data()
        return preset_to_name[str(data['fan_preset'])]

    def asusctl_info(self):
        data = {
            "graphics_mode": self._graphics_mode(),
            "graphics_power": self._graphics_power_status(),
            "profile": self._profile_status(),
            "turbo_enabled": self._profile_turbo(),
            "fan_preset": self._profile_fan_preset(),
        }
        return {
            'full_text': self.py3.safe_format(self.format, data),
            'cached_until': self.cached_until,
        }

if __name__ == "__main__":
    # Run in test mode

    from py3status.module_test import module_test
    module_test(Py3status)
