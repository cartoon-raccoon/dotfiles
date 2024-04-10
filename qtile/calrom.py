import subprocess
import json

from libqtile.widget import base

class Calrom(base.ThreadPoolText):
    """A widget to poll Calrom, to give the current
    day in the liturgical calendar of the Roman Catholic Church.

    Requires the command line tool `calrom`.
    """

    defaults = [
        (
            "update_interval",
            300,
            "Update Time in seconds"
        ),
        (
            "load_number",
            -1,
            "Number of celebrations to load. -1 loads all celebrations."
        )
        (
            "format",
            "{title} - C: {color}, R:{rank}"
        )
        (
            "colors",
            {
                "gold" : "#d79921",
                "green" : "#659157",
                "violet" : "#bf3efa",
                "rose" : "#fa8ce2",
                "blue" : "#2d728f",
                "red" : "#d12a48",
            },
            "Colours to use to show liturgical colors"
        ),
        (
            "display_color",
            "text",
            # text = as text, fore = as foreground, back = as background
            "Where to display the liturgical color."
        ),
        (
            "season_text",
            {
                "lent" : "Lent",
                "ordinary" : "Ordinary Time",
                "advent" : "Advent",
                "triduum" : "Triduum"
            },
            "Text to use when displaying season"
        )
        (
            "rank_text",
            {
                "solemnity" : "Sol",
                "feast" : "Fst",
                "memorial" : "Mem",
                "optional memorial" : "Opt",
                "ferial" : "Fer",
            },
            "Text to use when displaying rank"
        )
    ]

    # parses a cardinal number into its ordinal form
    ordinal = lambda n: "%d%s" % (n,"tsnrhtdd"[(n//10%10!=1)*(n%10<4)*n%10::4])

    def __init__(self, **config):
        super().__init__("", **config)
        self.add_defaults(Calrom.defaults)

    def get_data(self):
        proc = subprocess.run(["calrom", "--today", "--format=json"], capture_output=True)
        if proc.returncode != 0:
            return "calrom failed with error", proc.returncode
        
        p = json.loads(proc.stdout.decode())
        if self.load_number > len(p):
            l = len(p)
        else:
            l = self.load_number

        return p if l == -1 else p[0:l], proc.returncode
    
    def build_text(self, data: list[dict]):
        # todo
        pass

    def poll(self):
        data, code = self.get_data()
        if code != 0:
            return data
        return self.build_text(data)
